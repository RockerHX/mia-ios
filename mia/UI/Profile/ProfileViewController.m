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
#import "UIScrollView+MIARefresh.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Extrude.h"
#import "ProfileCollectionViewCell.h"
#import "ProfileHeaderView.h"
#import "MiaAPIHelper.h"
#import "WebSocketMgr.h"
#import "ProfileShareModel.h"
#import "FavoriteModel.h"
#import "DetailViewController.h"
#import "FavoriteViewController.h"
#import "FavoriteItem.h"
#import "SettingViewController.h"
#import "FavoriteMgr.h"
#import "PathHelper.h"
#import "UserSession.h"
#import "NSString+IsNull.h"
#import "UserSetting.h"
#import "Masonry.h"
#import "ShareViewController.h"
#import "HXAlertBanner.h"
#import "SongListPlayer.h"
#import "MusicMgr.h"
#import "FileLog.h"

static NSString * const kProfileCellReuseIdentifier 		= @"ProfileCellId";
static NSString * const kProfileBiggerCellReuseIdentifier 	= @"ProfileBiggerCellId";
static NSString * const kProfileHeaderReuseIdentifier 		= @"ProfileHeaderId";

static const CGFloat kProfileItemMarginH 	= 10;
static const CGFloat kProfileItemMarginV 	= 10;
static const CGFloat kProfileHeaderHeight 	= 240;

@interface ProfileViewController ()
<UICollectionViewDataSource
, UICollectionViewDelegate
, UICollectionViewDelegateFlowLayout
, ProfileHeaderViewDelegate
, FavoriteViewControllerDelegate
, FavoriteMgrDelegate
, DetailViewControllerDelegate
, SongListPlayerDelegate
, SongListPlayerDataSource
>

@end

@implementation ProfileViewController {
	SongListPlayer			*_songListPlayer;
	NSString 				*_uid;
	NSString 				*_nickName;
	BOOL 					_isMyProfile;
	BOOL 					_playingFavorite;

	long 					_currentPageStart;

	UICollectionView 		*_profileCollectionView;
	ProfileHeaderView 		*_profileHeaderView;
	FavoriteViewController	*_favoriteViewController;

	ProfileShareModel 		*_shareListModel;
	FavoriteModel 			*_favoriteModel;

	UIView					*_addShareView;
	UIView					*_noShareView;
	UIView					*_noNetWorkView;
}

- (id)initWitUID:(NSString *)uid nickName:(NSString *)nickName isMyProfile:(BOOL)isMyProfile {
	self = [super init];
	if (self) {
		_uid = uid;
		_nickName = nickName;
		_isMyProfile = isMyProfile;

		[self initUI];
		[self initData];
		[_profileCollectionView addFooterWithTarget:self action:@selector(requestShareList)];

		_favoriteViewController = [[FavoriteViewController alloc] initWitBackground:nil];
		_favoriteViewController.favoriteViewControllerDelegate = self;

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidAutoReconnectFailed:) name:WebSocketMgrNotificationDidAutoReconnectFailed object:nil];

		if (_isMyProfile) {
			[[UserSession standard] addObserver:self forKeyPath:UserSessionKey_NickName options:NSKeyValueObservingOptionNew context:nil];
		}
	}

	return self;
}

-(void)dealloc {
	_songListPlayer.dataSource = nil;
	_songListPlayer.delegate = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidAutoReconnectFailed object:nil];

	if (_isMyProfile) {
		[[UserSession standard] removeObserver:self forKeyPath:UserSessionKey_NickName context:nil];
	}
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

	[[FavoriteMgr standard] syncFavoriteList];
	if (_playFavoriteOnceTime) {
		_playFavoriteOnceTime = NO;

		if (!_playingFavorite) {
			[self playFavoriteMusic];
		}

		[_favoriteViewController setBackground:[UIImage getImageFromView:self.navigationController.view
																   frame:self.view.bounds]];
		[self.navigationController pushViewController:_favoriteViewController animated:YES];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
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

	//1.初始化layout
	UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
	//设置collectionView滚动方向
	//    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
	//设置headerView的尺寸大小
	if (_isMyProfile) {
		layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, kProfileHeaderHeight);
	} else {
		layout.headerReferenceSize = CGSizeZero;
	}

	//该方法也可以设置itemSize
	CGFloat itemWidth = (self.view.frame.size.width - kProfileItemMarginH * 3) / 2;
	layout.itemSize =CGSizeMake(itemWidth, itemWidth);

	//2.初始化collectionView
	_profileCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
	[self.view addSubview:_profileCollectionView];
	_profileCollectionView.backgroundColor = [UIColor whiteColor];

	//3.注册collectionViewCell
	//注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
	[_profileCollectionView registerClass:[ProfileCollectionViewCell class] forCellWithReuseIdentifier:kProfileCellReuseIdentifier];
	[_profileCollectionView registerClass:[ProfileCollectionViewCell class] forCellWithReuseIdentifier:kProfileBiggerCellReuseIdentifier];

	//注册headerView  此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致  均为reusableView
	[_profileCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kProfileHeaderReuseIdentifier];

	//4.设置代理
	_profileCollectionView.delegate = self;
	_profileCollectionView.dataSource = self;

	[self initHeaderView];
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

	if (_isMyProfile) {
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
}

- (void)initHeaderView {
	_profileHeaderView = [[ProfileHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kProfileHeaderHeight)];
	_profileHeaderView.profileHeaderViewDelegate = self;
}

- (void)initData {
	_shareListModel = [[ProfileShareModel alloc] init];
	[self requestShareList];
	[self checkPlaceHolder];

	[[FavoriteMgr standard] setCustomDelegate:self];
	_favoriteModel = [[FavoriteModel alloc] init];

	_songListPlayer = [[SongListPlayer alloc] initWithModelID:(long)(__bridge void *)self name:@"ProfileViewController Song List"];
	_songListPlayer.dataSource = self;
	_songListPlayer.delegate = self;
}

- (void)requestShareList {
	// 客人态第一个卡片占一行，为了保持最后一行有两个卡片，第一页的请求个数需要加一
	// 当如果这样的话，第二页的个数如果不一样的话，会导致数据重复
	// 第一页11个的最后一个，第二页10个的第一个
	// 解决方案：服务端的start不是分页，而是上一个id
	static const long kShareListPageCount = 10;
	++_currentPageStart;
	[MiaAPIHelper getShareListWithUID:_uid
								start:_currentPageStart
								 item:kShareListPageCount
						completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
							[_profileCollectionView footerEndRefreshing];

							NSArray *shareList = userInfo[@"v"][@"info"];
							if (!shareList) {
								[[FileLog standard] log:@"Profile requestShareList shareList is nil"];
								[self checkPlaceHolder];
								return;
							}

							[_shareListModel addSharesWithArray:shareList];
							[_profileCollectionView reloadData];
							[self checkPlaceHolder];
						} timeoutBlock:^(MiaRequestItem *requestItem) {
							[_profileCollectionView footerEndRefreshing];
							[self checkPlaceHolder];
						}];
}

- (void)initAddShareView {
	_addShareView = [[UIView alloc] init];
	[_profileCollectionView addSubview:_addShareView];
	[_addShareView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(noShareTouchAction:)]];

	UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[bgImageView setImage:[UIImage imageNamed:@"add_music_bg"]];
	[_addShareView addSubview:bgImageView];

	UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[logoImageView setImage:[UIImage imageNamed:@"add_music_logo"]];
	[_addShareView addSubview:logoImageView];

	MIALabel *addMusicLabel = [[MIALabel alloc] initWithFrame:CGRectZero
														   text:@"分享你喜欢的第一首歌"
														   font:UIFontFromSize(10.0f)
													  textColor:[UIColor blackColor]
												  textAlignment:NSTextAlignmentCenter
													numberLines:1];
	[_addShareView addSubview:addMusicLabel];

	[_addShareView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_profileCollectionView.mas_left).offset(kProfileItemMarginH);
		make.centerY.equalTo(_profileCollectionView.mas_centerY).offset(-15);
		CGFloat imageSize = (self.view.frame.size.width - kProfileItemMarginH * 3) / 2;
		make.size.mas_equalTo(CGSizeMake(imageSize, imageSize));
	}];

	[bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(_addShareView.mas_centerX);
		make.centerY.equalTo(_addShareView.mas_centerY);
		CGFloat imageSize = (self.view.frame.size.width - kProfileItemMarginH * 3) / 2;
		make.size.mas_equalTo(CGSizeMake(imageSize, imageSize));
	}];
	[logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(_addShareView.mas_centerX);
		make.centerY.equalTo(_addShareView.mas_centerY);
		make.size.mas_equalTo(CGSizeMake(45, 45));
	}];

	[addMusicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(_addShareView.mas_centerX);
		make.bottom.equalTo(bgImageView.mas_bottom).offset(-10);
		make.right.equalTo(_addShareView.mas_right);
	}];
}

- (void)initNoShareView {
	_noShareView = [[UIView alloc] init];
	[_profileCollectionView addSubview:_noShareView];

	UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[iconImageView setImage:[UIImage imageNamed:@"no_share"]];
	[_noShareView addSubview:iconImageView];

	MIALabel *wordLabel = [[MIALabel alloc] initWithFrame:CGRectZero
													 text:@"暂没有分享的歌曲"
													 font:UIFontFromSize(12.0f)
												textColor:[UIColor grayColor]
											textAlignment:NSTextAlignmentCenter
													numberLines:1];
	[_noShareView addSubview:wordLabel];

	[_noShareView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(_profileCollectionView.mas_centerX);
		make.centerY.equalTo(_profileCollectionView.mas_centerY).offset(-150);
	}];

	[iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(_noShareView.mas_top);
		make.left.equalTo(_noShareView.mas_left);
		make.right.equalTo(_noShareView.mas_right);
		make.centerX.equalTo(_noShareView.mas_centerX);
		make.size.mas_equalTo(CGSizeMake(75, 75));
	}];
	[wordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(_noShareView.mas_centerX);
		make.top.equalTo(iconImageView.mas_bottom).offset(10);
		make.bottom.equalTo(_noShareView.mas_bottom);
	}];
}


- (void)initNoNetworkView {
	_noNetWorkView = [[UIView alloc] init];
	[_profileCollectionView addSubview:_noNetWorkView];

	UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[iconImageView setImage:[UIImage imageNamed:@"NN-WiFiIcon"]];
	[_noNetWorkView addSubview:iconImageView];

	MIALabel *wordLabel = [[MIALabel alloc] initWithFrame:CGRectZero
														   text:@"网络未连接"
														   font:UIFontFromSize(12.0f)
													  textColor:[UIColor grayColor]
												  textAlignment:NSTextAlignmentCenter
													numberLines:1];
	[_noNetWorkView addSubview:wordLabel];

	[_noNetWorkView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(_profileCollectionView.mas_centerX);
		if (_isMyProfile) {
			make.centerY.equalTo(_profileCollectionView.mas_centerY);
		} else {
			make.centerY.equalTo(_profileCollectionView.mas_centerY).offset(-150);
		}

	}];

	[iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(_noNetWorkView.mas_top);
		make.left.equalTo(_noNetWorkView.mas_left);
		make.right.equalTo(_noNetWorkView.mas_right);
		make.centerX.equalTo(_noNetWorkView.mas_centerX);
		make.size.mas_equalTo(CGSizeMake(75, 75));
	}];
	[wordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(_noNetWorkView.mas_centerX);
		make.top.equalTo(iconImageView.mas_bottom).offset(10);
		make.bottom.equalTo(_noNetWorkView.mas_bottom);
	}];
}

- (void)checkPlaceHolder {
	// 先统一隐藏下，检查后会重新显示其中一个或都不显示
	[self hidePlaceHolder];
	if ([_shareListModel.dataSource count] > 0) {
		return;
	}

	if ([[WebSocketMgr standard] isOpen]) {
		if (_isMyProfile) {
			if (_addShareView) {
				[_addShareView setHidden:NO];
				return;
			}
			[self initAddShareView];
		} else {
			if (_noShareView) {
				[_noShareView setHidden:NO];
				return;
			}
			[self initNoShareView];
		}

	} else {
		if (_noNetWorkView) {
			[_noNetWorkView setHidden:NO];
			return;
		}

		[self initNoNetworkView];
	}

}

- (void)hidePlaceHolder {
	[_addShareView setHidden:YES];
	[_noShareView setHidden:YES];
	[_noNetWorkView setHidden:YES];

	return;
}

#pragma mark - delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return _shareListModel.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	if (!_isMyProfile && indexPath.row == 0) {
		ProfileCollectionViewCell *cell = (ProfileCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kProfileBiggerCellReuseIdentifier
																												 forIndexPath:indexPath];
		cell.isBiggerCell = YES;
		cell.isMyProfile = _isMyProfile;
		cell.shareItem = _shareListModel.dataSource[indexPath.row];
		return cell;
	} else {
		ProfileCollectionViewCell *cell = (ProfileCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kProfileCellReuseIdentifier

																												 forIndexPath:indexPath];
		cell.isBiggerCell = NO;
		cell.isMyProfile = _isMyProfile;
		cell.shareItem = _shareListModel.dataSource[indexPath.row];
		return cell;
	}
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat itemWidth = (self.view.frame.size.width - kProfileItemMarginH * 3) / 2;

	// 如果是客人态的话，第一个cell显示成长方形
	if (!_isMyProfile && indexPath.row == 0) {
		return CGSizeMake(self.view.frame.size.width - 2 * kProfileItemMarginH, itemWidth);
	} else {
		return CGSizeMake(itemWidth, itemWidth);
	}
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
	return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
	return kProfileItemMarginH;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
	return kProfileItemMarginV;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	if (!_isMyProfile)
		return nil;

	if ([kind isEqual:UICollectionElementKindSectionHeader]) {
		UICollectionReusableView *contentView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kProfileHeaderReuseIdentifier forIndexPath:indexPath];
		if (contentView.subviews.count == 0) {
			[contentView addSubview:_profileHeaderView];
		}
		return contentView;
	} else {
		NSLog(@"It's maybe a bug.");
		return nil;
	}
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	ProfileCollectionViewCell *cell = (ProfileCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

	[MiaAPIHelper postReadCommentWithsID:[[cell shareItem] sID]
	 completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
		 NSLog(@"post read comment ret: %d", success);
	 } timeoutBlock:^(MiaRequestItem *requestItem) {
		 NSLog(@"post read comment timeout");
	 }];

	DetailViewController *vc = [[DetailViewController alloc] initWitShareItem:[cell shareItem] fromMyProfile:_isMyProfile];
	vc.customDelegate = self;
	[self.navigationController pushViewController:vc animated:YES];
}

- (FavoriteModel *)profileHeaderViewModel {
	return _favoriteModel;
}

- (void)profileHeaderViewDidTouchedCover {
	if (!_playingFavorite) {
		[self playFavoriteMusic];
	}

	[_favoriteViewController setBackground:[UIImage getImageFromView:self.navigationController.view
															  frame:self.view.bounds]];
	[self.navigationController pushViewController:_favoriteViewController animated:YES];

}

- (void)profileHeaderViewDidTouchedPlay {
	if (!_playingFavorite) {
		[self playFavoriteMusic];
	} else {
		if ([_songListPlayer isPlaying]) {
			[self pauseMusic];
		} else {
			[self playFavoriteMusic];
		}
	}
}

- (void)favoriteMgrDidFinishSync {
	NSArray *items = [self favoriteViewControllerGetFavoriteList];
	[_favoriteModel addItemsWithArray:items];
	if (_favoriteViewController) {
		[_favoriteViewController.favoriteCollectionView reloadData];
	}

	[_profileHeaderView updateFavoriteCount];
}

- (void)favoriteMgrDidFinishDownload {
	if (_favoriteViewController) {
		[_favoriteViewController.favoriteCollectionView reloadData];
	}
	[_profileHeaderView updateFavoriteCount];
}

- (FavoriteModel *)favoriteViewControllerModel {
	return _favoriteModel;
}

- (NSArray *)favoriteViewControllerGetFavoriteList {
	return [[FavoriteMgr standard] getFavoriteListFromIndex:_favoriteModel.dataSource.count];
}

- (BOOL)favoriteViewControllerDeleteMusics {
	BOOL isChanged = NO;
	BOOL deletePlaying = NO;
	NSMutableArray *idArray = [[NSMutableArray alloc] init];
	NSEnumerator *enumerator = [_favoriteModel.dataSource reverseObjectEnumerator];
	for (FavoriteItem *item in enumerator) {
		if (item.isSelected) {
			if (item.isPlaying) {
				deletePlaying = YES;
			}

			[idArray addObject:item.sID];
			[_favoriteModel.dataSource removeObject:item];
			isChanged = YES;
		}
	}

	[[FavoriteMgr standard] removeSelectedItems];
	if (isChanged) {
		if (deletePlaying) {
			if ([_favoriteModel.dataSource count] > 0) {
				[self playFavoriteMusic];
			} else {
				[self pauseMusic];
			}
		}

		[_profileHeaderView updateFavoriteCount];
	}

	[MiaAPIHelper deleteFavoritesWithIDs:idArray completeBlock:
	 ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
		 if (success) {
			 [HXAlertBanner showWithMessage:@"删除收藏成功" tap:nil];
		 } else {
			 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
			 [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"删除收藏失败:%@", error] tap:nil];
		 }
	 } timeoutBlock:^(MiaRequestItem *requestItem) {
		 [HXAlertBanner showWithMessage:@"收藏失败，网络请求超时" tap:nil];

	}];

	return isChanged;
}

- (void)favoriteViewControllerPlayMusic:(NSInteger)row {
	if (_favoriteModel.dataSource.count <= 0) {
		return;
	}

	FavoriteItem *aFavoriteItem = _favoriteModel.dataSource[row];
	[self playFavoriteMusicWithoutCheckNetwork:aFavoriteItem];
}

- (void)favoriteViewControllerPauseMusic {
	[self pauseMusic];
}

- (void)detailViewControllerDidDeleteShare {
	// 删除分享后需要从新获取分享列表
	_currentPageStart = 0;
	[_shareListModel.dataSource removeAllObjects];
	[self checkPlaceHolder];
	[self requestShareList];
}

#pragma mark - SongListPlayerDataSource
- (NSInteger)songListPlayerCurrentItemIndex {
	return _favoriteModel.currentPlaying;
}

- (MusicItem *)songListPlayerItemAtIndex:(NSInteger)index {
	FavoriteItem *aFavoriteItem =  _favoriteModel.dataSource[index];
	return [aFavoriteItem.music copy];
}

#pragma mark - SongListPlayerDelegate
- (void)songListPlayerDidPlay {
	[_profileHeaderView setIsPlaying:YES];
}

- (void)songListPlayerDidPause {
	[_profileHeaderView setIsPlaying:NO];
}

- (void)songListPlayerDidCompletion {
	if (_playingFavorite) {
		_favoriteModel.currentPlaying++;
		[self playFavoriteMusic];
		if (_favoriteViewController) {
			[_favoriteViewController.favoriteCollectionView reloadData];
		}
	}
}


#pragma mark - Notification

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//	NSLog(@"keyPath = %@, change = %@, context = %s", keyPath, change, (char *)context);
	if ([keyPath isEqualToString:UserSessionKey_NickName]) {
		NSString *newNickName = change[NSKeyValueChangeNewKey];
		self.title = [NSString isNull:newNickName] ? @"" : newNickName;
	}
}

- (void)notificationWebSocketDidAutoReconnectFailed:(NSNotification *)notification {
	[self checkPlaceHolder];
}

#pragma mark - audio operations
- (void)playFavoriteMusic {
	if (_favoriteModel.dataSource.count <= 0) {
		return;
	}

	FavoriteItem *itemForPlay = _favoriteModel.dataSource[_favoriteModel.currentPlaying];

	// Wifi环境或者歌曲已经缓存，直接播放
	if ([[WebSocketMgr standard] isWifiNetwork] || [[FavoriteMgr standard] isItemCached:itemForPlay]) {
		[self playFavoriteMusicWithoutCheckNetwork:itemForPlay];
		return;
	}

	// 用户允许3G环境下播放歌曲
	if ([UserSetting isAllowedToPlayNowWithURL:itemForPlay.music.murl]) {
		[self playFavoriteMusicWithoutCheckNetwork:itemForPlay];
		return;
	}

	// 寻找下一首已经缓存了的歌曲
	itemForPlay = nil;
	for (FavoriteItem *item in _favoriteModel.dataSource) {
		if ([[FavoriteMgr standard] isItemCached:item]) {
			itemForPlay = item;
			break;
		}
	}

	if (nil == itemForPlay) {
		NSLog(@"没有可以播放的离线歌曲");
		return;
	}

	[self playFavoriteMusicWithoutCheckNetwork:itemForPlay];
}


- (void)playFavoriteMusicWithoutCheckNetwork:(FavoriteItem *)aFavoriteItem {
	if (!aFavoriteItem) {
		NSLog(@"FavoriteItem is nil, play was ignored.");
		return;
	}

	MusicItem *musicItem = [aFavoriteItem.music copy];
	if (!musicItem.murl || !musicItem.name || !musicItem.singerName) {
		NSLog(@"Music is nil, stop play it.");
		return;
	}

	if (aFavoriteItem.isCached && [[FavoriteMgr standard] isItemCached:aFavoriteItem]) {
		musicItem.murl = [NSString stringWithFormat:@"file://%@", [PathHelper genMusicFilenameWithUrl:musicItem.murl]];
	} else {
		NSLog(@"收藏中播放还未下载的歌曲");
	}

	_playingFavorite = YES;

	[[MusicMgr standard] setCurrentPlayer:_songListPlayer];
	[_songListPlayer playWithMusicItem:musicItem];

	[_profileHeaderView setIsPlaying:YES];
	[_favoriteViewController setIsPlaying:YES];
}

- (void)pauseMusic {
	[_songListPlayer pause];
	[_profileHeaderView setIsPlaying:NO];
	[_favoriteViewController setIsPlaying:NO];
}

#pragma mark - button Actions

- (void)backButtonAction:(id)sender {
	if (_playingFavorite) {
		[_songListPlayer stop];
	}

	if (_customDelegate) {
		[_customDelegate profileViewControllerWillDismiss];
	}
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)settingButtonAction:(id)sender {
	NSLog(@"setting button clicked.");
	SettingViewController *vc = [[SettingViewController alloc] init];
	[self.navigationController pushViewController:vc animated:YES];
}

- (void)noShareTouchAction:(id)sender {
	ShareViewController *vc = [[ShareViewController alloc] init];
	[self.navigationController pushViewController:vc animated:YES];
}

@end
