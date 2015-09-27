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
#import "ProfileCollectionViewCell.h"
#import "MiaAPIHelper.h"
#import "WebSocketMgr.h"
#import "FavoriteModel.h"
#import "DetailViewController.h"

static NSString * const kProfileCellReuseIdentifier 		= @"ProfileCellId";
static NSString * const kProfileBiggerCellReuseIdentifier 	= @"ProfileBiggerCellId";
static NSString * const kProfileHeaderReuseIdentifier 		= @"ProfileHeaderId";

static const CGFloat kFavoriteCVMarginTop	= 200;
static const CGFloat kProfileItemMarginH 	= 10;
static const CGFloat kProfileItemMarginV 	= 10;
static const CGFloat kProfileHeaderHeight 	= 64;
static const CGFloat kFavoriteItemHeight	= 50;

@interface FavoriteViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@end

@implementation FavoriteViewController {
	NSString * _uid;
	NSString *_nickName;

	long currentPageStart;

	UICollectionView *mainCollectionView;
	UIView *favoriteHeaderView;
	FavoriteModel *favoriteModel;
}

- (id)initWitBackground:(UIImage *)backgroundImage {
	self = [super init];
	if (self) {
		[self initBackground:backgroundImage];
		[self initTopView];
		[self initCollectionView];
		[self initData];

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
	UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	[bgView setImageToBlur:backgroundImage blurRadius:3.0 completionBlock:nil];
	[self.view addSubview:bgView];
}

- (void)initTopView {
	UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kFavoriteCVMarginTop)];
	[self.view addSubview:topView];

	UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedTopView)];
	gesture.numberOfTapsRequired = 1;
	[topView addGestureRecognizer:gesture];
}

- (void)initCollectionView {
	//1.初始化layout
	UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
	//设置collectionView滚动方向
	//    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
	//设置headerView的尺寸大小
	layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, kProfileHeaderHeight);

	//该方法也可以设置itemSize
	CGFloat itemWidth = self.view.frame.size.width - kProfileItemMarginH * 2;
	layout.itemSize =CGSizeMake(itemWidth, kFavoriteItemHeight);

	//2.初始化collectionView
	mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,
																			kFavoriteCVMarginTop,
																			self.view.bounds.size.width,
																			self.view.bounds.size.height - kFavoriteCVMarginTop)
											collectionViewLayout:layout];
	[self.view addSubview:mainCollectionView];
	mainCollectionView.backgroundColor = [UIColor whiteColor];
	mainCollectionView.alpha = 0.9;

	//3.注册collectionViewCell
	//注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
	[mainCollectionView registerClass:[ProfileCollectionViewCell class] forCellWithReuseIdentifier:kProfileCellReuseIdentifier];

	//注册headerView  此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致  均为reusableView
	[mainCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kProfileHeaderReuseIdentifier];

	//4.设置代理
	mainCollectionView.delegate = self;
	mainCollectionView.dataSource = self;

	[mainCollectionView addFooterWithTarget:self action:@selector(requestFavoriteList)];

	[self initHeaderView];
}

- (void)initHeaderView {
	favoriteHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kProfileHeaderHeight)];
	favoriteHeaderView.backgroundColor = [UIColor yellowColor];
}

- (void)initData {
	favoriteModel = [[FavoriteModel alloc] init];

	[self requestFavoriteList];
}

- (void)requestFavoriteList {
	static const long kFavoritePageItemCount	= 10;
	[MiaAPIHelper getFavoriteListWithStart:0 item:kFavoritePageItemCount];
}

#pragma mark - delegate

#pragma mark collectionView代理方法

//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return favoriteModel.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	ProfileCollectionViewCell *cell = (ProfileCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kProfileCellReuseIdentifier

																												 forIndexPath:indexPath];
//	cell.isBiggerCell = NO;
//	cell.isMyProfile = _isMyProfile;
//	cell.shareItem = favoriteModel.dataSource[indexPath.row];
	return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat itemWidth = self.view.frame.size.width - kProfileItemMarginH * 2;
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
	return kProfileItemMarginH;
}


//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
	return kProfileItemMarginV;
}


//通过设置SupplementaryViewOfKind 来设置头部或者底部的view，其中 ReuseIdentifier 的值必须和 注册是填写的一致，本例都为 “reusableView”
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	if ([kind isEqual:UICollectionElementKindSectionHeader]) {
		UICollectionReusableView *contentView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kProfileHeaderReuseIdentifier forIndexPath:indexPath];
		if (contentView.subviews.count == 0) {
			[contentView addSubview:favoriteHeaderView];
		}
		return contentView;
	} else {
		NSLog(@"It's maybe a bug.");
		return nil;
	}
}

//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	ProfileCollectionViewCell *cell = (ProfileCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

	DetailViewController *vc = [[DetailViewController alloc] initWitShareItem:cell.shareItem];
	[self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Notification

- (void)notificationWebSocketDidReceiveMessage:(NSNotification *)notification {
	NSString *command = [notification userInfo][MiaAPIKey_ServerCommand];
	id ret = [notification userInfo][MiaAPIKey_Values][MiaAPIKey_Return];
	//NSLog(@"%@", command);

	if ([command isEqualToString:MiaAPICommand_User_GetStart]) {
		[self handleGetFavoriteListWitRet:[ret intValue] userInfo:[notification userInfo]];
	}
}

- (void)handleGetFavoriteListWitRet:(int)ret userInfo:(NSDictionary *) userInfo {
	[mainCollectionView footerEndRefreshing];

	NSArray *items = userInfo[@"v"][@"info"];
	if (!items)
		return;

	[favoriteModel addItemsWithArray:items];
	[mainCollectionView reloadData];
}


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

@end
