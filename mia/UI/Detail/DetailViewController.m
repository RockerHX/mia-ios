//
//  DetailViewController.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "DetailViewController.h"
#import "MIAButton.h"
#import "MIALabel.h"
#import "MBProgressHUD.h"
#import "MBProgressHUDHelp.h"
#import "UIScrollView+MIARefresh.h"
#import "UIImageView+WebCache.h"
#import "CommentCollectionViewCell.h"
#import "DetailHeaderView.h"
#import "MiaAPIHelper.h"
#import "WebSocketMgr.h"
#import "ProfileShareModel.h"
#import "DetailViewController.h"
#import "CommentModel.h"

static NSString * const kProfileCellReuseIdentifier = @"ProfileCellId";
static NSString * const kProfileHeaderReuseIdentifier = @"ProfileHeaderId";

static const CGFloat kProfileItemMarginH 	= 15;
static const CGFloat kProfileItemMarginV 	= 20;
static const CGFloat kProfileHeight 		= 350;
static const CGFloat kCommentItemHeight 	= 40;

@interface DetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIActionSheetDelegate>

@end

@implementation DetailViewController {
	ShareItem *shareItem;

	long currentCommentStart;

	UICollectionView *mainCollectionView;
	CommentModel *commentModel;
}

- (id)initWitShareItem:(ShareItem *)item {
	self = [super init];
	if (self) {
		shareItem = item;
		[self initUI];
		[self initData];
		[mainCollectionView addFooterWithTarget:self action:@selector(requestComments)];

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
	static NSString *kDetailTitle = @"详情页";
	self.title = kDetailTitle;
	[self initBarButton];

	//1.初始化layout
	UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
	//设置collectionView滚动方向
	//    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
	//设置headerView的尺寸大小
	layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, kProfileHeight);

	//该方法也可以设置itemSize
	CGFloat itemWidth = self.view.frame.size.width - kProfileItemMarginH * 2;
	layout.itemSize = CGSizeMake(itemWidth, kCommentItemHeight);

	//2.初始化collectionView
	mainCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
	[self.view addSubview:mainCollectionView];
	mainCollectionView.backgroundColor = [UIColor whiteColor];

	//3.注册collectionViewCell
	//注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
	[mainCollectionView registerClass:[CommentCollectionViewCell class] forCellWithReuseIdentifier:kProfileCellReuseIdentifier];

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

	UIImage *moreButtonImage = [UIImage imageNamed:@"more"];
	MIAButton *moreButton = [[MIAButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, moreButtonImage.size.width, moreButtonImage.size.height)
												 titleString:nil
												  titleColor:nil
														font:nil
													 logoImg:nil
											 backgroundImage:moreButtonImage];
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
	self.navigationItem.rightBarButtonItem = rightButton;
	[moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initHeaderView:(UIView *)headerView {
	DetailHeaderView *detailHeaderView = [[DetailHeaderView alloc] initWithFrame:headerView.bounds];
	detailHeaderView.shareItem = shareItem;
	[headerView addSubview:detailHeaderView];
}

- (void)initData {
	commentModel = [[CommentModel alloc] init];
	[self requestComments];
}

- (void)requestComments {
	static const long kCommentPageItemCount	= 10;
	//[MiaAPIHelper getMusicCommentWithShareID:shareItem.sID start:commentModel.dataSource.count item:kCommentPageItemCount];
	// for test
	[MiaAPIHelper getMusicCommentWithShareID:@"244" start:commentModel.dataSource.count item:kCommentPageItemCount];
}

#pragma mark - delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	const NSInteger kButtonIndex_Report = 0;
	if (kButtonIndex_Report == buttonIndex) {
		MBProgressHUD *progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
		[self.view addSubview:progressHUD];
		progressHUD.labelText = NSLocalizedString(@"举报成功", nil);
		progressHUD.mode = MBProgressHUDModeText;
		[progressHUD showAnimated:YES whileExecutingBlock:^{
			sleep(2);
		} completionBlock:^{
			[progressHUD removeFromSuperview];
		}];

	}
}

#pragma mark collectionView代理方法

//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return commentModel.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	CommentCollectionViewCell *cell = (CommentCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kProfileCellReuseIdentifier
																											 forIndexPath:indexPath];
	[cell updateWithCommentItem:commentModel.dataSource[indexPath.row]];
	return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat itemWidth = self.view.frame.size.width - kProfileItemMarginH * 2;
	return CGSizeMake(itemWidth, kCommentItemHeight);
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
//	ProfileCollectionViewCell *cell = (ProfileCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
//
//	DetailViewController *vc = [[DetailViewController alloc] initWitShareItem:cell.shareItem];
//	[self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Notification

- (void)notificationWebSocketDidReceiveMessage:(NSNotification *)notification {
	NSString *command = [notification userInfo][MiaAPIKey_ServerCommand];
	id ret = [notification userInfo][MiaAPIKey_Values][MiaAPIKey_Return];
	//NSLog(@"%@", command);

	if ([command isEqualToString:MiaAPICommand_Music_GetMcomm]) {
		[self handleGetMusicCommentWitRet:[ret intValue] userInfo:[notification userInfo]];
	}
}

- (void)handleGetMusicCommentWitRet:(int)ret userInfo:(NSDictionary *) userInfo {
	[mainCollectionView footerEndRefreshing];

	if (0 != ret)
		return;
	NSArray *commentArray = userInfo[@"v"][@"info"];
	if (!commentArray || [commentArray count] <= 0)
		return;

	[commentModel addComments:commentArray];
	[mainCollectionView reloadData];
}

#pragma mark - button Actions

- (void)backButtonAction:(id)sender {
	NSLog(@"back button clicked.");
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)moreButtonAction:(id)sender {
	NSLog(@"more button clicked.");
	UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:@"更多操作"
													 delegate:self
											cancelButtonTitle:@"取消"
									   destructiveButtonTitle:@"举报"
											otherButtonTitles: nil];
	[sheet showInView:self.view];
}

@end
