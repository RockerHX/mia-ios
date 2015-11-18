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
#import "UICollectionViewLeftAlignedLayout.h"

static NSString * const kProfileCellReuseIdentifier 		= @"ProfileCellId";
static NSString * const kProfileHeaderReuseIdentifier 		= @"ProfileHeaderId";
static const CGFloat kProfileHeaderHeight					= 220;

static const long kDefaultPageFrom			= 1;		// 分享的分页起始，服务器定的

@interface GuestProfileViewController ()
<UICollectionViewDataSource
, UICollectionViewDelegate
, UICollectionViewDelegateFlowLayout
, HXMusicDetailViewControllerDelegate
>

@end

@implementation GuestProfileViewController {
	NSString 				*_uid;
	NSString 				*_nickName;

	long 					_currentPageStart;

	UIView					*_headerView;
	UIImageView 			*_avatarImageView;

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

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
	return NO;
}

- (void)initUI {
	self.title = _nickName;

	_headerView = [[UIView alloc] initWithFrame:CGRectMake(0,
														   0,
														   self.view.bounds.size.width,
														   kProfileHeaderHeight)];
	_headerView.backgroundColor = [UIColor whiteColor];
	[self initHeaderView:_headerView];

	[self initCollectionView];
	[self initNoShareView];

	[_profileCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(self.view.mas_top);
		make.left.equalTo(self.view.mas_left);
		make.right.equalTo(self.view.mas_right);
		make.bottom.equalTo(self.view.mas_bottom);
	}];
}

- (void)initHeaderView:(UIView *)contentView {
	UIImage *backButtonImage = [UIImage imageNamed:@"back"];
	MIAButton *backButton = [[MIAButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, backButtonImage.size.width, backButtonImage.size.height * 2)
												 titleString:nil
												  titleColor:nil
														font:nil
													 logoImg:backButtonImage
											 backgroundImage:nil];
	[backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[contentView addSubview:backButton];

	[backButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(contentView.mas_left).offset(13);
		make.top.equalTo(contentView.mas_top).offset(30);
	}];

	static CGFloat kAvatarWidth = 70;
	_avatarImageView = [[UIImageView alloc] init];
	_avatarImageView.layer.cornerRadius = kAvatarWidth / 2;
	_avatarImageView.clipsToBounds = YES;
	_avatarImageView.layer.borderWidth = 0.5f;
	_avatarImageView.layer.borderColor = UIColorFromHex(@"808080", 1.0).CGColor;
	[_avatarImageView setImage:[UIImage imageNamed:@"HP-InfectUserDefaultHeader"]];
	[contentView addSubview:_avatarImageView];

	MIALabel *nickNameLabel = [[MIALabel alloc] initWithFrame:CGRectZero
															text:_nickName
															font:UIFontFromSize(17.0f)
													   textColor:[UIColor blackColor]
												   textAlignment:NSTextAlignmentLeft
													 numberLines:1];
	[contentView addSubview:nickNameLabel];

	[_avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.size.mas_equalTo(CGSizeMake(kAvatarWidth, kAvatarWidth));
		make.centerX.equalTo(contentView.mas_centerX);
		make.top.equalTo(contentView.mas_top).offset(85);
		make.bottom.equalTo(contentView.mas_bottom).offset(-65);
	}];

	[nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(contentView.mas_centerX);
		make.top.equalTo(_avatarImageView.mas_bottom).offset(10);
	}];
}

- (void)initCollectionView {
	//1.初始化layout
	UICollectionViewLeftAlignedLayout *layout = [[UICollectionViewLeftAlignedLayout alloc] init];

	//设置headerView的尺寸大小
	layout.headerReferenceSize = CGSizeMake(self.view.bounds.size.width, kProfileHeaderHeight);

	//2.初始化collectionView
	_profileCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
	[self.view addSubview:_profileCollectionView];
	_profileCollectionView.backgroundColor = [UIColor whiteColor];

	//3.注册collectionViewCell
	//注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
	[_profileCollectionView registerClass:[ProfileCollectionViewCell class] forCellWithReuseIdentifier:kProfileCellReuseIdentifier];

	//注册headerView  此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致  均为reusableView
	[_profileCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kProfileHeaderReuseIdentifier];

	//4.设置代理
	_profileCollectionView.delegate = self;
	_profileCollectionView.dataSource = self;

	MJRefreshBackNormalFooter *aFooter = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(requestShareList)];
	[aFooter setTitle:@"上拉加载更多" forState:MJRefreshStateIdle];
	[aFooter setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
	_profileCollectionView.mj_footer = aFooter;
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
							[_profileCollectionView.mj_footer endRefreshing];
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
								[HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
								[self checkPlaceHolder];
							}

						} timeoutBlock:^(MiaRequestItem *requestItem) {
							[_profileCollectionView.mj_footer endRefreshing];
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
	ProfileCollectionViewCell *cell = (ProfileCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kProfileCellReuseIdentifier forIndexPath:indexPath];
	cell.isBiggerCell = NO;
	cell.isMyProfile = NO;
	cell.shareItem = _shareListModel.dataSource[indexPath.row];
	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat itemWidth = (self.view.frame.size.width - kProfileItemMarginH * 3) / 2;
	return CGSizeMake(itemWidth, itemWidth);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
	return UIEdgeInsetsMake(1, 15, 15, 15);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
	return kProfileItemMarginH;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
	return kProfileItemMarginV;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	if ([kind isEqual:UICollectionElementKindSectionHeader]) {
		UICollectionReusableView *contentView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kProfileHeaderReuseIdentifier forIndexPath:indexPath];
		if (contentView.subviews.count == 0) {
			[contentView addSubview:_headerView];
		}
		return contentView;
	} else {
		NSLog(@"It's maybe a bug.");
		return nil;
	}
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	ProfileCollectionViewCell *cell = (ProfileCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

	HXMusicDetailViewController *musicDetailViewController = [[UIStoryboard storyboardWithName:@"MusicDetail" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([HXMusicDetailViewController class])];
	musicDetailViewController.playItem = [cell shareItem];
	musicDetailViewController.fromProfile = NO;
	musicDetailViewController.customDelegate = self;
	[self.navigationController pushViewController:musicDetailViewController animated:YES];
}

#pragma mark - HXMusicDetailViewControllerDelegate
- (void)detailViewControllerDismissWithoutDelete {
	[_profileCollectionView reloadData];
}

#pragma mark - button Actions

- (void)backButtonAction:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

@end
