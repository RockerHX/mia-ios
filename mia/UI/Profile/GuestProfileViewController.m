//
//  GuestProfileViewController.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "GuestProfileViewController.h"
#import "MIAButton.h"
#import "MIALabel.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Extrude.h"
#import "ProfileCollectionViewCell.h"
#import "ProfileHeaderView.h"
#import "MiaAPIHelper.h"
#import "WebSocketMgr.h"
#import "ProfileShareModel.h"
#import "PathHelper.h"
#import "UserSession.h"
#import "NSString+IsNull.h"
#import "UserSetting.h"
#import "Masonry.h"
#import "HXAlertBanner.h"
#import "FileLog.h"
#import "HXMusicDetailViewController.h"
#import "MJRefresh.h"

static NSString * const kProfileCellReuseIdentifier 		= @"ProfileCellId";
static NSString * const kProfileBiggerCellReuseIdentifier 	= @"ProfileBiggerCellId";

static const long kDefaultPageFrom			= 1;		// 分享的分页起始，服务器定的

@interface GuestProfileViewController ()
<UICollectionViewDataSource
, UICollectionViewDelegate
, UICollectionViewDelegateFlowLayout
>

@end

@implementation GuestProfileViewController {
	NSString 				*_uid;
	NSString 				*_nickName;

	long 					_currentPageStart;

	UICollectionView 		*_profileCollectionView;
	ProfileShareModel 		*_shareListModel;
	UIView					*_noShareView;
}

- (id)initWitUID:(NSString *)uid nickName:(NSString *)nickName {
	self = [super init];
	if (self) {
		_uid = uid;
		_nickName = nickName;
	}

	return self;
}

-(void)dealloc {
}

- (void)viewDidLoad {
	[super viewDidLoad];

	[self initUI];
	[self initData];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
	return NO;
}

- (void)initUI {
	self.title = _nickName;
	[self initBarButton];
	[self initCollectionView];
	[self initNoShareView];
}

- (void)initCollectionView {
	//1.初始化layout
	UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];

	//设置headerView的尺寸大小
	layout.headerReferenceSize = CGSizeZero;

	//2.初始化collectionView
	_profileCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
	[self.view addSubview:_profileCollectionView];
	_profileCollectionView.backgroundColor = [UIColor whiteColor];

	//3.注册collectionViewCell
	//注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
	[_profileCollectionView registerClass:[ProfileCollectionViewCell class] forCellWithReuseIdentifier:kProfileCellReuseIdentifier];
	[_profileCollectionView registerClass:[ProfileCollectionViewCell class] forCellWithReuseIdentifier:kProfileBiggerCellReuseIdentifier];

	//4.设置代理
	_profileCollectionView.delegate = self;
	_profileCollectionView.dataSource = self;

	MJRefreshAutoNormalFooter *aFooter = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(requestShareList)];
	[aFooter setTitle:@"上拉加载更多" forState:MJRefreshStateIdle];
	[aFooter setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
	_profileCollectionView.footer = aFooter;
}

- (void)initBarButton {
	UIImage *backButtonImage = [UIImage imageNamed:@"back"];
	MIAButton *backButton = [[MIAButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, backButtonImage.size.width, backButtonImage.size.height * 2)
												 titleString:nil
												  titleColor:nil
														font:nil
													 logoImg:backButtonImage
											 backgroundImage:nil];
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	self.navigationItem.leftBarButtonItem = leftButton;
	[backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initData {
	_shareListModel = [[ProfileShareModel alloc] init];
	_currentPageStart = kDefaultPageFrom;
	[self requestShareList];
}

- (void)requestShareList {
	// 客人态第一个卡片占一行，为了保持最后一行有两个卡片，第一页的请求个数需要加一
	// 当如果这样的话，第二页的个数如果不一样的话，会导致数据重复
	// 第一页11个的最后一个，第二页10个的第一个
	// 解决方案：服务端的start不是分页，而是上一个id
	static const long kShareListPageCount = 10;
	[MiaAPIHelper getShareListWithUID:_uid
								start:_currentPageStart
								 item:kShareListPageCount
						completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
							[_profileCollectionView.footer endRefreshing];
							if (success) {
								NSArray *shareList = userInfo[@"v"][@"info"];
								if ([shareList count] <= 0) {
									[[FileLog standard] log:@"Profile requestShareList shareList is nil"];
									[self checkPlaceHolder];
									return;
								}

								[_shareListModel addSharesWithArray:shareList];
								[_profileCollectionView reloadData];
								++_currentPageStart;
								[self checkPlaceHolder];
							} else {
								id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
								[HXAlertBanner showWithMessage:[NSString stringWithFormat:@"无法获取分享列表:%@", error] tap:nil];
								[self checkPlaceHolder];
							}

						} timeoutBlock:^(MiaRequestItem *requestItem) {
							[_profileCollectionView.footer endRefreshing];
							[self checkPlaceHolder];
							if ([[WebSocketMgr standard] isOpen]) {
								[HXAlertBanner showWithMessage:@"无法获取分享列表，网络请求超时" tap:nil];
							}
						}];
}

- (void)initNoShareView {
	_noShareView = [[UIView alloc] init];
	[_profileCollectionView addSubview:_noShareView];

	UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[iconImageView setImage:[UIImage imageNamed:@"no_share"]];
	[_noShareView addSubview:iconImageView];
	[_noShareView setHidden:YES];

	MIALabel *wordLabel = [[MIALabel alloc] initWithFrame:CGRectZero
													 text:@"暂没有分享的歌曲"
													 font:UIFontFromSize(14.0f)
												textColor:UIColorFromHex(@"808080", 1.0)
											textAlignment:NSTextAlignmentCenter
													numberLines:1];
	[_noShareView addSubview:wordLabel];

	[_noShareView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(_profileCollectionView.mas_centerX);
		make.centerY.equalTo(_profileCollectionView.mas_centerY).offset(-135);
	}];

	[iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(_noShareView.mas_top);
		make.left.equalTo(_noShareView.mas_left);
		make.right.equalTo(_noShareView.mas_right);
		make.centerX.equalTo(_noShareView.mas_centerX);
		make.size.mas_equalTo(CGSizeMake(70, 70));
	}];
	[wordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(_noShareView.mas_centerX);
		make.top.equalTo(iconImageView.mas_bottom).offset(10);
		make.bottom.equalTo(_noShareView.mas_bottom);
	}];
}

- (void)checkPlaceHolder {
	if ([_shareListModel.dataSource count] > 0) {
		[_noShareView setHidden:YES];
		return;
	}

	[_noShareView setHidden:NO];
}

#pragma mark - delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return _shareListModel.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) {
		ProfileCollectionViewCell *cell = (ProfileCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kProfileBiggerCellReuseIdentifier forIndexPath:indexPath];
		cell.isBiggerCell = YES;
		cell.isMyProfile = NO;
		cell.shareItem = _shareListModel.dataSource[indexPath.row];
		return cell;
	} else {
		ProfileCollectionViewCell *cell = (ProfileCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kProfileCellReuseIdentifier forIndexPath:indexPath];
		cell.isBiggerCell = NO;
		cell.isMyProfile = NO;
		cell.shareItem = _shareListModel.dataSource[indexPath.row];
		return cell;
	}
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat itemWidth = (self.view.frame.size.width - kProfileItemMarginH * 3) / 2;
	if (indexPath.row == 0) {
		return CGSizeMake(self.view.frame.size.width - 2 * kProfileItemMarginH, itemWidth);
	} else {
		return CGSizeMake(itemWidth, itemWidth);
	}
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
	return UIEdgeInsetsMake(15, 15, 15, 15);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
	return kProfileItemMarginH;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
	return kProfileItemMarginV;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	ProfileCollectionViewCell *cell = (ProfileCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

	[MiaAPIHelper postReadCommentWithsID:[[cell shareItem] sID]
	 completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
		 NSLog(@"post read comment ret: %d, %d", success, [userInfo[MiaAPIKey_Values][@"num"] intValue]);
	 } timeoutBlock:^(MiaRequestItem *requestItem) {
		 NSLog(@"post read comment timeout");
	 }];

	HXMusicDetailViewController *musicDetailViewController = [[UIStoryboard storyboardWithName:@"MusicDetail" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([HXMusicDetailViewController class])];
	musicDetailViewController.playItem = [cell shareItem];
	musicDetailViewController.fromProfile = NO;
	[self.navigationController pushViewController:musicDetailViewController animated:YES];
}

#pragma mark - button Actions

- (void)backButtonAction:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

@end
