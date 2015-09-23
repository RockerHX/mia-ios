//
//  ProfileViewController.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "ProfileViewController.h"
#import "MIAButton.h"
#import "MIALabel.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+BlurredImage.h"
#import "ProfileCollectionViewCell.h"

static NSString * const kProfileCellReuseIdentifier = @"ProfileCellId";
static NSString * const kProfileHeaderReuseIdentifier = @"ProfileHeaderId";
static const CGFloat kProfileItemMarginH = 10;
static const CGFloat kProfileItemMarginV = 10;
static const CGFloat kProfileHeight = 240;

@interface ProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@end

@implementation ProfileViewController {
	UICollectionView *mainCollectionView;
}

-(void)dealloc {
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self initUI];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:animated];
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
	return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
	return NO;
}

- (void)initUI {
	static NSString *kProfileTitle = @"Profile";
	self.title = kProfileTitle;
	[self initBarButton];

//	ProfileTableView *tableView = [[ProfileTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
//	[self.view addSubview:tableView];

	//1.初始化layout
	UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
	//设置collectionView滚动方向
	//    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
	//设置headerView的尺寸大小
	layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, kProfileHeight);
	//该方法也可以设置itemSize
	CGFloat itemWidth = (self.view.frame.size.width - kProfileItemMarginH * 3) / 2;
	layout.itemSize =CGSizeMake(itemWidth, itemWidth);

	//2.初始化collectionView
	mainCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
	[self.view addSubview:mainCollectionView];
	mainCollectionView.backgroundColor = [UIColor whiteColor];

	//3.注册collectionViewCell
	//注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
	[mainCollectionView registerClass:[ProfileCollectionViewCell class] forCellWithReuseIdentifier:kProfileCellReuseIdentifier];

	//注册headerView  此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致  均为reusableView
	[mainCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kProfileHeaderReuseIdentifier];

	//4.设置代理
	mainCollectionView.delegate = self;
	mainCollectionView.dataSource = self;
}

- (void)initBarButton {
	UIImage *backButtonImage = [UIImage imageNamed:@"back"];
	MIAButton *backButton = [[MIAButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, backButtonImage.size.width, backButtonImage.size.height)
												 titleString:nil
												  titleColor:nil
														font:nil
													 logoImg:nil
											 backgroundImage:backButtonImage];
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	self.navigationItem.leftBarButtonItem = leftButton;
	[backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];

	UIImage *settingButtonImage = [UIImage imageNamed:@"setting"];
	MIAButton *settingButton = [[MIAButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, settingButtonImage.size.width, settingButtonImage.size.height)
												 titleString:nil
												  titleColor:nil
														font:nil
													 logoImg:nil
											 backgroundImage:settingButtonImage];
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:settingButton];
	self.navigationItem.rightBarButtonItem = rightButton;
	[settingButton addTarget:self action:@selector(settingButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initHeaderView:(UIView *)headerView {
	//headerView.backgroundColor = [UIColor brownColor];

	static const CGFloat kCoverMarginTop = 44;
	static const CGFloat kCoverHeight = kProfileHeight - kCoverMarginTop * 2;
	static const CGFloat kPlayButtonMarginRight = 76;
	static const CGFloat kPlayButtonMarginTop = 109;
	static const CGFloat kPlayButtonWidth = 40;

	CGRect coverFrame = CGRectMake(0,
								   kCoverMarginTop,
								   headerView.frame.size.width,
								   kCoverHeight);
	UIImageView *coverImageView = [[UIImageView alloc] initWithFrame:coverFrame];
	//[coverImageView setImage:[UIImage imageNamed:@"default_cover"]];
	[coverImageView setImageToBlur:[UIImage imageNamed:@"default_cover"] blurRadius:6.0 completionBlock:nil];
	[headerView addSubview:coverImageView];
	UIImageView *coverMaskImageView = [[UIImageView alloc] initWithFrame:coverFrame];
	[coverMaskImageView setImage:[UIImage imageNamed:@"cover_mask"]];
	[headerView addSubview:coverMaskImageView];

	MIAButton *playButton = [[MIAButton alloc] initWithFrame:CGRectMake(headerView.frame.size.width - kPlayButtonMarginRight - kPlayButtonWidth,
															 kPlayButtonMarginTop,
															 kPlayButtonWidth,
															 kPlayButtonWidth)
									  titleString:nil
									   titleColor:nil
											 font:nil
										  logoImg:nil
								  backgroundImage:nil];
	[playButton setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
	[playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:playButton];

	const static CGFloat kFavoriteCountLabelMarginRight		= 220;
	const static CGFloat kFavoriteCountLabelMarginTop		= 108;
	const static CGFloat kFavoriteCountLabelHeight			= 38;

	static const CGFloat kFavoriteMiddleLabelMarginRight 	= 120;
	static const CGFloat kFavoriteMiddleLabelMarginTop 		= 108;
	static const CGFloat kFavoriteMiddleLabelWidth 			= 100;
	static const CGFloat kFavoriteMiddleLabelHeight 		= 20;

	static const CGFloat kCachedCountLabelMarginRight 		= 120;
	static const CGFloat kCachedCountLabelMarginTop 		= 130;
	static const CGFloat kCachedCountLabelWidth 			= 100;
	static const CGFloat kCachedCountLabelHeight 			= 20;

	MIALabel *favoriteCountLabel = [[MIALabel alloc] initWithFrame:CGRectMake(0,
																		 kFavoriteCountLabelMarginTop,
																		 headerView.frame.size.width - kFavoriteCountLabelMarginRight,
																		 kFavoriteCountLabelHeight)
														 text:@"30"
														 font:UIFontFromSize(35.0f)
														 textColor:[UIColor whiteColor]
									   textAlignment:NSTextAlignmentRight
												  numberLines:1];
	//favoriteCountLabel.backgroundColor = [UIColor blueColor];
	[headerView addSubview:favoriteCountLabel];

	MIALabel *favoriteMiddleLabel = [[MIALabel alloc] initWithFrame:CGRectMake(headerView.frame.size.width - kFavoriteMiddleLabelMarginRight - kFavoriteMiddleLabelWidth,
																			  kFavoriteMiddleLabelMarginTop,
																			  kFavoriteMiddleLabelWidth,
																			  kFavoriteMiddleLabelHeight)
															  text:@"首收藏歌曲》"
															  font:UIFontFromSize(16.0f)
														 textColor:[UIColor whiteColor]
													 textAlignment:NSTextAlignmentRight
													   numberLines:1];
	//favoriteMiddleLabel.backgroundColor = [UIColor greenColor];
	[headerView addSubview:favoriteMiddleLabel];

	MIALabel *cachedCountLabel = [[MIALabel alloc] initWithFrame:CGRectMake(headerView.frame.size.width - kCachedCountLabelMarginRight - kCachedCountLabelWidth,
																			   kCachedCountLabelMarginTop,
																			   kCachedCountLabelWidth,
																			   kCachedCountLabelHeight)
															   text:@"28首已下载到本地"
															   font:UIFontFromSize(12.0f)
														  textColor:[UIColor whiteColor]
													  textAlignment:NSTextAlignmentLeft
														numberLines:1];
	//cachedCountLabel.backgroundColor = [UIColor greenColor];
	[headerView addSubview:cachedCountLabel];

	const static CGFloat kFavoriteIconMarginLeft	= 15;
	const static CGFloat kFavoriteIconMarginTop		= 15;
	const static CGFloat kFavoriteIconMarginWidth	= 16;

	const static CGFloat kFavoriteLabelMarginLeft	= kFavoriteIconMarginLeft + kFavoriteIconMarginWidth + 8;
	const static CGFloat kFavoriteLabelMarginTop	= 13;
	const static CGFloat kFavoriteLabelWidth		= 30;
	const static CGFloat kFavoriteLabelHeight		= 20;

	const static CGFloat kShareIconMarginLeft		= 15;
	const static CGFloat kShareIconMarginTop		= 15 + kCoverHeight + kCoverMarginTop;;
	const static CGFloat kShareIconMarginWidth		= 16;

	const static CGFloat kShareLabelMarginLeft		= kShareIconMarginLeft + kShareIconMarginWidth + 8;
	const static CGFloat kShareLabelMarginTop		= 13 + kCoverHeight + kCoverMarginTop;
	const static CGFloat kShareLabelWidth			= 30;
	const static CGFloat kShareLabelHeight			= 20;


	// 两个子标题
	UIImageView *favoriteIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kFavoriteIconMarginLeft,
																				kFavoriteIconMarginTop,
																				kFavoriteIconMarginWidth,
																				kFavoriteIconMarginWidth)];
	[favoriteIconImageView setImage:[UIImage imageNamed:@"favorite_white"]];
	[headerView addSubview:favoriteIconImageView];
	MIALabel *favoriteLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kFavoriteLabelMarginLeft,
														  kFavoriteLabelMarginTop,
														  kFavoriteLabelWidth,
														  kFavoriteLabelHeight)
										  text:@"收藏"
										  font:UIFontFromSize(12.0f)
										   textColor:UIColorFromHex(@"a2a2a2", 1.0)
									   textAlignment:NSTextAlignmentLeft
								   numberLines:1];
	[headerView addSubview:favoriteLabel];

	UIImageView *shareIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kShareIconMarginLeft,
																					   kShareIconMarginTop,
																					   kShareIconMarginWidth,
																					   kShareIconMarginWidth)];
	[shareIconImageView setImage:[UIImage imageNamed:@"share"]];
	[headerView addSubview:shareIconImageView];
	MIALabel *shareLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kShareLabelMarginLeft,
																		 kShareLabelMarginTop,
																		 kShareLabelWidth,
																		 kShareLabelHeight)
														 text:@"分享"
														 font:UIFontFromSize(12.0f)
										   textColor:UIColorFromHex(@"a2a2a2", 1.0)
									   textAlignment:NSTextAlignmentLeft
												  numberLines:1];
	[headerView addSubview:shareLabel];

	static const CGFloat kWifiTipsLabelMarginTop 	= kCoverHeight + kCoverMarginTop - 25;
	static const CGFloat kWifiTipsLabelHeight		= 20;

	MIALabel *wifiTipsLabel = [[MIALabel alloc] initWithFrame:CGRectMake(0,
																		 kWifiTipsLabelMarginTop,
																		 headerView.frame.size.width,
																		 kWifiTipsLabelHeight)
														 text:@"在非WIFI网络下，播放收藏歌曲不产生任何流量"
														 font:UIFontFromSize(12.0f)
										   textColor:[UIColor whiteColor]
									   textAlignment:NSTextAlignmentCenter
												  numberLines:1];
	[headerView addSubview:wifiTipsLabel];

}

#pragma mark - delegate

#pragma mark collectionView代理方法

//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return 9;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	ProfileCollectionViewCell *cell = (ProfileCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kProfileCellReuseIdentifier
																											 forIndexPath:indexPath];
	cell.botlabel.text = [NSString stringWithFormat:@"{%ld,%ld}",(long)indexPath.section,(long)indexPath.row];
	cell.backgroundColor = [UIColor yellowColor];

	return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat itemWidth = (self.view.frame.size.width - kProfileItemMarginH * 3) / 2;
	return CGSizeMake(itemWidth, itemWidth);
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
	UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kProfileHeaderReuseIdentifier forIndexPath:indexPath];

	[self initHeaderView:headerView];

	return headerView;
}

//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	ProfileCollectionViewCell *cell = (ProfileCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
	NSString *msg = cell.botlabel.text;
	NSLog(@"%@",msg);
}

#pragma mark - Notification


#pragma mark - button Actions

- (void)backButtonAction:(id)sender {
	NSLog(@"back button clicked.");
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)settingButtonAction:(id)sender {
	NSLog(@"setting button clicked.");
}

- (void)playButtonAction:(id)sender {
	NSLog(@"play button clicked.");
}

@end
