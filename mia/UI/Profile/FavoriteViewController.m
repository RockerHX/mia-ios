//
//  FavoriteViewController.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "FavoriteViewController.h"
#import "MIAButton.h"
#import "MIALabel.h"
#import "UIScrollView+MIARefresh.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+BlurredImage.h"
#import "FavoriteCollectionViewCell.h"
#import "MiaAPIHelper.h"
#import "WebSocketMgr.h"
#import "DetailViewController.h"
#import "MIALabel.h"

static NSString * const kFavoriteCellReuseIdentifier 		= @"FavoriteCellId";
//static NSString * const kFavoriteHeaderReuseIdentifier 		= @"FavoriteHeaderId";

static const CGFloat kFavoriteCVMarginTop	= 200;
static const CGFloat kFavoriteItemMarginH 	= 10;
static const CGFloat kFavoriteItemMarginV 	= 10;
static const CGFloat kFavoriteHeaderHeight 	= 64;
static const CGFloat kFavoriteItemHeight	= 50;
const static CGFloat kBottomViewHeight 		= 40;
const static CGFloat kFavoriteAlpha 		= 0.9;

@interface FavoriteViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@end

@implementation FavoriteViewController {
	NSString * _uid;
	NSString *_nickName;

	long currentPageStart;

	UIImageView *bgView;
	MIAButton *editButton;
	MIAButton *closeButton;

	UIView *favoriteHeaderView;
	MIAButton *playButton;

	BOOL isEditing;
}

- (id)initWitBackground:(UIImage *)backgroundImage {
	self = [super init];
	if (self) {
		[self initBackground:backgroundImage];
		[self initTopView];
		[self initHeaderView];
		[self initCollectionView];
		[self initBottomView];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidReceiveMessage:) name:WebSocketMgrNotificationDidReceiveMessage object:nil];
	}

	return self;
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidReceiveMessage object:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated;
{
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
	return NO;
}

- (void)initBackground:(UIImage *)backgroundImage {
//	self.view.backgroundColor = [UIColor redColor];
//	NSLog(@"bg: %f, %f %f", backgroundImage.size.width, backgroundImage.size.height, backgroundImage.scale);
//	NSLog(@"bounds: %@", NSStringFromCGRect(self.view.bounds));
	bgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	if (backgroundImage) {
		[bgView setImageToBlur:backgroundImage blurRadius:3.0 completionBlock:nil];
	}
	[self.view addSubview:bgView];
}

- (void)setBackground:(UIImage *)backgroundImage {
	[bgView setImageToBlur:backgroundImage blurRadius:3.0 completionBlock:nil];
}

- (void)initTopView {
	UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kFavoriteCVMarginTop)];
	[self.view addSubview:topView];

	UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedTopView)];
	gesture.numberOfTapsRequired = 1;
	[topView addGestureRecognizer:gesture];
}

- (void)initBottomView {
	const static CGFloat kLineViewHeight = 1;

	UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - kBottomViewHeight, self.view.bounds.size.width, kBottomViewHeight)];
	bottomView.backgroundColor = [UIColor whiteColor];
	bottomView.alpha = kFavoriteAlpha;
	[self.view addSubview:bottomView];

	UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bottomView.bounds.size.width, kLineViewHeight)];
	lineView.backgroundColor = UIColorFromHex(@"d2d2d2", 1.0);
	[bottomView addSubview:lineView];

	closeButton = [[MIAButton alloc] initWithFrame:CGRectMake(0,
																		kLineViewHeight,
																		bottomView.bounds.size.width,
																		bottomView.bounds.size.height - kLineViewHeight)
												 titleString:@"关闭"
												  titleColor:UIColorFromHex(@"ff300e", 1.0)
														font:UIFontFromSize(16)
													 logoImg:nil
											 backgroundImage:nil];
	[closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[bottomView addSubview:closeButton];
}

- (void)initCollectionView {
	//1.初始化layout
	UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
	//设置collectionView滚动方向
	//    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
	//设置headerView的尺寸大小
	//layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, kFavoriteHeaderHeight);

	//该方法也可以设置itemSize
	CGFloat itemWidth = self.view.frame.size.width - kFavoriteItemMarginH * 2;
	layout.itemSize =CGSizeMake(itemWidth, kFavoriteItemHeight);

	//2.初始化collectionView
	_favoriteCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,
																			kFavoriteCVMarginTop + kFavoriteHeaderHeight,
																			self.view.bounds.size.width,
																			self.view.bounds.size.height - kFavoriteCVMarginTop - kBottomViewHeight)
											collectionViewLayout:layout];
	[self.view addSubview:_favoriteCollectionView];
	_favoriteCollectionView.backgroundColor = [UIColor whiteColor];
	_favoriteCollectionView.alpha = kFavoriteAlpha;

	//3.注册collectionViewCell
	//注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
	[_favoriteCollectionView registerClass:[FavoriteCollectionViewCell class] forCellWithReuseIdentifier:kFavoriteCellReuseIdentifier];

	//注册headerView  此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致  均为reusableView
//	[_favoriteCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kFavoriteHeaderReuseIdentifier];

	//4.设置代理
	_favoriteCollectionView.delegate = self;
	_favoriteCollectionView.dataSource = self;

	[_favoriteCollectionView addFooterWithTarget:self action:@selector(requestFavoriteList)];
}

- (void)initHeaderView {
	favoriteHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, kFavoriteCVMarginTop, self.view.bounds.size.width, kFavoriteHeaderHeight)];
	favoriteHeaderView.backgroundColor = [UIColor whiteColor];
	favoriteHeaderView.alpha = kFavoriteAlpha;
	[self.view addSubview:favoriteHeaderView];

	static const CGFloat kTitleMarginLeft		= 15;
	static const CGFloat kTitleMarginTop		= 15;
	static const CGFloat kTitleWidth			= 100;
	static const CGFloat kTitleHeight			= 20;

	MIALabel *titleLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kTitleMarginLeft,
														  kTitleMarginTop,
														  kTitleWidth,
														  kTitleHeight)
										  text:@"收藏(30首)"
										  font:UIFontFromSize(16.0f)
										   textColor:[UIColor blackColor]
									   textAlignment:NSTextAlignmentLeft
								   numberLines:1];
	titleLabel.backgroundColor = [UIColor greenColor];
	[favoriteHeaderView addSubview:titleLabel];

	static const CGFloat kPlayButtonMarginLeft		= 115;
	static const CGFloat kPlayButtonMarginTop		= 15;
	static const CGFloat kPlayButtonWidth			= 16;
	static const CGFloat kPlayButtonHeight			= 16;

	playButton = [[MIAButton alloc] initWithFrame:CGRectMake(kPlayButtonMarginLeft,
																		kPlayButtonMarginTop,
																		kPlayButtonWidth,
																		kPlayButtonHeight)
									  titleString:nil
									   titleColor:nil
											 font:nil
										  logoImg:nil
								  backgroundImage:[UIImage imageNamed:@"play_black"]];
	[playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	playButton.backgroundColor = [UIColor yellowColor];
	[favoriteHeaderView addSubview:playButton];

	static const CGFloat kEditButtonMarginRight		= 15;
	static const CGFloat kEditButtonMarginTop		= 15;
	static const CGFloat kEditButtonWidth			= 40;
	static const CGFloat kEditButtonHeight			= 20;

	editButton = [[MIAButton alloc] initWithFrame:CGRectMake(favoriteHeaderView.bounds.size.width - kEditButtonMarginRight - kEditButtonWidth,
																		kEditButtonMarginTop,
																		kEditButtonWidth,
																		kEditButtonHeight)
												 titleString:@"编辑"
												  titleColor:[UIColor redColor]
														font:UIFontFromSize(12)
													 logoImg:nil
											 backgroundImage:nil];
	[editButton addTarget:self action:@selector(editButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[favoriteHeaderView addSubview:editButton];

}

- (void)setIsPlaying:(BOOL)isPlaying {
	_isPlaying = isPlaying;
	if (isPlaying) {
		[playButton setBackgroundImage:[UIImage imageNamed:@"puase_black"] forState:UIControlStateNormal];
	} else {
		[playButton setBackgroundImage:[UIImage imageNamed:@"play_black"] forState:UIControlStateNormal];
	}
}

- (void)requestFavoriteList {
	[_favoriteViewControllerDelegate favoriteViewControllerRequestFavoriteList];
}

- (void)endRequestFavoriteList:(BOOL)isSuccessed {
	[_favoriteCollectionView footerEndRefreshing];
}

#pragma mark - delegate

#pragma mark collectionView代理方法

//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [_favoriteViewControllerDelegate favoriteViewControllerModel].dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	FavoriteCollectionViewCell *cell = (FavoriteCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kFavoriteCellReuseIdentifier
																												 forIndexPath:indexPath];
	cell.rowIndex = indexPath.row;
	cell.isEditing = isEditing;
	if ([_favoriteViewControllerDelegate favoriteViewControllerModel].currentPlaying == indexPath.row) {
		NSLog(@"-------> %ld", indexPath.row);
		cell.isPlaying = YES;
	} else {
		cell.isPlaying = NO;
	}
	cell.favoriteItem = [_favoriteViewControllerDelegate favoriteViewControllerModel].dataSource[indexPath.row];
	
	return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat itemWidth = self.view.frame.size.width - kFavoriteItemMarginH * 2;
	return CGSizeMake(itemWidth, kFavoriteItemHeight);
}

//footer的size
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
//{
//    return CGSizeMake(10, 10);
//}

//header的size
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
//{
//    return CGSizeMake(10, 10);
//}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
	return UIEdgeInsetsMake(10, 10, 10, 10);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
	return kFavoriteItemMarginH;
}


//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
	return kFavoriteItemMarginV;
}


//通过设置SupplementaryViewOfKind 来设置头部或者底部的view，其中 ReuseIdentifier 的值必须和 注册是填写的一致，本例都为 “reusableView”
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//	if ([kind isEqual:UICollectionElementKindSectionHeader]) {
//		UICollectionReusableView *contentView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kFavoriteHeaderReuseIdentifier forIndexPath:indexPath];
//		if (contentView.subviews.count == 0) {
//			[contentView addSubview:favoriteHeaderView];
//		}
//		return contentView;
//	} else {
		NSLog(@"It's maybe a bug.");
		return nil;
//	}
}

//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger lastPlayingRow = [_favoriteViewControllerDelegate favoriteViewControllerModel].currentPlaying;
	if (lastPlayingRow == indexPath.row)
		return;

	NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:lastPlayingRow inSection:0];
	FavoriteCollectionViewCell *lastPlayingCell = (FavoriteCollectionViewCell *)[collectionView cellForItemAtIndexPath:lastIndexPath];
	lastPlayingCell.isPlaying = NO;

	FavoriteCollectionViewCell *currentPlayingCell = (FavoriteCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
	currentPlayingCell.isPlaying = YES;

	[_favoriteViewControllerDelegate favoriteViewControllerModel].currentPlaying = indexPath.row;
	[_favoriteViewControllerDelegate favoriteViewControllerPlayMusic:[_favoriteViewControllerDelegate favoriteViewControllerModel].currentPlaying];

	[_favoriteCollectionView reloadItemsAtIndexPaths:[[NSArray alloc] initWithObjects:lastIndexPath, indexPath, nil]];
}

#pragma mark - Notification

- (void)notificationWebSocketDidReceiveMessage:(NSNotification *)notification {
//	NSString *command = [notification userInfo][MiaAPIKey_ServerCommand];
//	id ret = [notification userInfo][MiaAPIKey_Values][MiaAPIKey_Return];
	//NSLog(@"%@", command);
}

//- (void)handleGetFavoriteListWitRet:(int)ret userInfo:(NSDictionary *) userInfo {
//	[_favoriteCollectionView footerEndRefreshing];
//
//	NSArray *items = userInfo[@"v"][@"data"];
//	if (!items)
//		return;
//
//	[[_favoriteViewControllerDelegate favoriteViewControllerModel] addItemsWithArray:items];
//	[_favoriteCollectionView reloadData];
//}


#pragma mark - button Actions

- (void)backButtonAction:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)settingButtonAction:(id)sender {
	NSLog(@"setting button clicked.");
}

- (void)touchedTopView {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)playButtonAction:(id)sender {
	if (_isPlaying) {
		[_favoriteViewControllerDelegate favoriteViewControllerPauseMusic];
	} else {
		[_favoriteViewControllerDelegate favoriteViewControllerPlayMusic:[_favoriteViewControllerDelegate favoriteViewControllerModel].currentPlaying];
	}
}

- (void)editButtonAction:(id)sender {
	isEditing = !isEditing;
	[_favoriteCollectionView reloadData];
	if (isEditing) {
		[editButton setTitle:@"完成" forState:UIControlStateNormal];
		[closeButton setTitle:@"删除" forState:UIControlStateNormal];
	} else {
		[editButton setTitle:@"编辑" forState:UIControlStateNormal];
		[closeButton setTitle:@"关闭" forState:UIControlStateNormal];
	}
}

- (void)closeButtonAction:(id)sender {
	if (isEditing) {
		// TODO delete
		NSLog(@"del sth.");
		for (FavoriteItem *it in [_favoriteViewControllerDelegate favoriteViewControllerModel].dataSource) {
			NSLog(@"------is selected:%d", it.isSelected);
		}
	} else {
		[self.navigationController popViewControllerAnimated:YES];
	}

}

@end
