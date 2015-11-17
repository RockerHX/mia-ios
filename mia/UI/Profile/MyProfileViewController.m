//
//  MyProfileViewController.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "MyProfileViewController.h"
#import "MIAButton.h"
#import "MIALabel.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Extrude.h"
#import "ProfileCollectionViewCell.h"
#import "ProfileHeaderView.h"
#import "MiaAPIHelper.h"
#import "WebSocketMgr.h"
#import "ProfileShareModel.h"
#import "FavoriteViewController.h"
#import "FavoriteItem.h"
#import "SettingViewController.h"
#import "FavoriteMgr.h"
#import "PathHelper.h"
#import "UserSession.h"
#import "NSString+IsNull.h"
#import "UserSetting.h"
#import "Masonry.h"
#import "HXShareViewController.h"
#import "HXAlertBanner.h"
#import "SongListPlayer.h"
#import "MusicMgr.h"
#import "FileLog.h"
#import "HXMusicDetailViewController.h"
#import "MJRefresh.h"

static NSString * const kProfileCellReuseIdentifier 		= @"ProfileCellId";
static NSString * const kProfileHeaderReuseIdentifier 		= @"ProfileHeaderId";

static const CGFloat kProfileHeaderHeight 	= 240;
static const long kDefaultPageFrom			= 1;		// 分享的分页起始，服务器定的

@interface MyProfileViewController ()
<UICollectionViewDataSource
, UICollectionViewDelegate
, UICollectionViewDelegateFlowLayout
, ProfileHeaderViewDelegate
, FavoriteViewControllerDelegate
, FavoriteMgrDelegate
, HXMusicDetailViewControllerDelegate
, SongListPlayerDelegate
, SongListPlayerDataSource
, HXShareViewControllerDelegate
>

@end

@implementation MyProfileViewController {
	SongListPlayer			*_songListPlayer;
	NSString 				*_uid;
	NSString 				*_nickName;
	BOOL 					_isMyProfile;
	BOOL 					_playingFavorite;

	long 					_currentPageStart;

	UICollectionView 		*_collectionView;
	ProfileHeaderView 		*_headerView;

	FavoriteViewController	*_favoriteViewController;
	ProfileShareModel 		*_shareListModel;

	UIView					*_addShareView;
	UIView					*_noShareView;
	UIView					*_noNetWorkView;
}

- (instancetype)initWitUID:(NSString *)uid nickName:(NSString *)nickName {
	self = [super init];
	if (self) {
		_uid = uid;
		_nickName = nickName;
		_isMyProfile = YES;

		[self initUI];
		[self initData];

		_favoriteViewController = [[FavoriteViewController alloc] initWitBackground:nil];
		_favoriteViewController.favoriteViewControllerDelegate = self;

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidAutoReconnectFailed:) name:WebSocketMgrNotificationDidAutoReconnectFailed object:nil];

		if (_isMyProfile) {
			[[UserSession standard] addObserver:self forKeyPath:UserSessionKey_NickName options:NSKeyValueObservingOptionNew context:nil];
		}
	}

	return self;
}

- (void)dealloc {
	_songListPlayer.dataSource = nil;
	_songListPlayer.delegate = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidAutoReconnectFailed object:nil];

	if (_isMyProfile) {
		[[UserSession standard] removeObserver:self forKeyPath:UserSessionKey_NickName context:nil];
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

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

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
	return NO;
}

- (void)initUI {
	self.title = _nickName;
	[self initBarButton];
	[self initHeaderView];
	[self initCollectionView];
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


	if (_isMyProfile) {
		UIImage *settingButtonImage = [UIImage imageNamed:@"setting"];
		MIAButton *settingButton = [[MIAButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, settingButtonImage.size.width, settingButtonImage.size.height * 2)
														titleString:nil
														 titleColor:nil
															   font:nil
															logoImg:settingButtonImage
													backgroundImage:nil];
		UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:settingButton];
		self.navigationItem.rightBarButtonItem = rightButton;
		[settingButton addTarget:self action:@selector(settingButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	}
}

- (void)initHeaderView {
	_headerView = [[ProfileHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kProfileHeaderHeight)];
	_headerView.profileHeaderViewDelegate = self;
}

- (void)initCollectionView {
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
	_collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
	[self.view addSubview:_collectionView];
	_collectionView.backgroundColor = [UIColor whiteColor];

	//3.注册collectionViewCell
	//注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
	[_collectionView registerClass:[ProfileCollectionViewCell class] forCellWithReuseIdentifier:kProfileCellReuseIdentifier];

	//注册headerView  此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致  均为reusableView
	[_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kProfileHeaderReuseIdentifier];

	//4.设置代理
	_collectionView.delegate = self;
	_collectionView.dataSource = self;

	MJRefreshBackNormalFooter *aFooter = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(requestShareList)];
	[aFooter setTitle:@"上拉加载更多" forState:MJRefreshStateIdle];
	[aFooter setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
	_collectionView.mj_footer = aFooter;
}

- (void)initData {
	// 分享数据
	_shareListModel = [[ProfileShareModel alloc] init];
	_currentPageStart = kDefaultPageFrom;
	[self requestShareList];

	// 收藏数据
	[[FavoriteMgr standard] setCustomDelegate:self];
	[[FavoriteMgr standard] syncFavoriteList];

	// 播放器
	_songListPlayer = [[SongListPlayer alloc] initWithModelID:(long)(__bridge void *)self name:@"MyProfileViewController Song List"];
	_songListPlayer.dataSource = self;
	_songListPlayer.delegate = self;
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
							[_collectionView.mj_footer endRefreshing];
							if (success) {
								NSArray *shareList = userInfo[@"v"][@"info"];
								if ([shareList count] <= 0) {
									[[FileLog standard] log:@"Profile requestShareList shareList is nil"];
									[self checkPlaceHolder];
									return;
								}

								[_shareListModel addSharesWithArray:shareList];
								[_collectionView reloadData];
								++_currentPageStart;
								[self checkPlaceHolder];
							} else {
								id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
								[HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
								[self checkPlaceHolder];
							}

						} timeoutBlock:^(MiaRequestItem *requestItem) {
							[_collectionView.mj_footer endRefreshing];
							[self checkPlaceHolder];
							if ([[WebSocketMgr standard] isOpen]) {
								[HXAlertBanner showWithMessage:@"无法获取分享列表，网络请求超时" tap:nil];
							}
						}];
}

- (void)initAddShareView {
	_addShareView = [[UIView alloc] init];
	[_collectionView addSubview:_addShareView];
	[_addShareView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(noShareTouchAction:)]];

	UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[bgImageView setImage:[UIImage imageNamed:@"C-AddMusicBG"]];
	[_addShareView addSubview:bgImageView];

	UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[logoImageView setImage:[UIImage imageNamed:@"C-AddMusicIcon"]];
	[_addShareView addSubview:logoImageView];

	MIALabel *addMusicLabel = [[MIALabel alloc] initWithFrame:CGRectZero
														   text:@"分享你喜欢的第一首歌"
														   font:UIFontFromSize(14.0f)
													  textColor:UIColorFromHex(@"808080", 1.0)
												  textAlignment:NSTextAlignmentCenter
													numberLines:1];
	[_addShareView addSubview:addMusicLabel];

	[_addShareView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_collectionView.mas_left).offset(kProfileItemMarginH);
		make.top.mas_equalTo(kProfileHeaderHeight);
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

- (void)initNoNetworkView {
	_noNetWorkView = [[UIView alloc] init];
	[_collectionView addSubview:_noNetWorkView];

	UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[iconImageView setImage:[UIImage imageNamed:@"NN-WiFiIcon"]];
	[_noNetWorkView addSubview:iconImageView];

	MIALabel *wordLabel = [[MIALabel alloc] initWithFrame:CGRectZero
														   text:@"网络未连接"
														   font:UIFontFromSize(16.0f)
													  textColor:UIColorFromHex(@"808080", 1.0)
												  textAlignment:NSTextAlignmentCenter
													numberLines:1];
	[_noNetWorkView addSubview:wordLabel];

	[_noNetWorkView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(_collectionView.mas_centerX);
		make.top.mas_equalTo(kProfileHeaderHeight + 60);
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
		if (_addShareView) {
			[_addShareView setHidden:NO];
			return;
		}
		[self initAddShareView];

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
	ProfileCollectionViewCell *cell = (ProfileCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kProfileCellReuseIdentifier

																											 forIndexPath:indexPath];
	cell.isBiggerCell = NO;
	cell.isMyProfile = _isMyProfile;
	cell.shareItem = _shareListModel.dataSource[indexPath.row];
	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat itemWidth = (self.view.frame.size.width - kProfileItemMarginH * 3) / 2;
	return CGSizeMake(itemWidth, itemWidth);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
	return UIEdgeInsetsMake(0, 15, 0, 15);
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

	[MiaAPIHelper postReadCommentWithsID:[[cell shareItem] sID]
	 completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
		 NSLog(@"post read comment ret: %d, %d", success, [userInfo[MiaAPIKey_Values][@"num"] intValue]);
		 if (_customDelegate) {
			 [_customDelegate myProfileViewControllerUpdateUnreadCount:[userInfo[MiaAPIKey_Values][@"num"] intValue]];
		 }

	 } timeoutBlock:^(MiaRequestItem *requestItem) {
		 NSLog(@"post read comment timeout");
	 }];

	// 点击查看详情就把本地的未读评论清掉
	cell.shareItem.newCommCnt = 0;

	HXMusicDetailViewController *musicDetailViewController = [[UIStoryboard storyboardWithName:@"MusicDetail" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([HXMusicDetailViewController class])];
	musicDetailViewController.playItem = [cell shareItem];
	musicDetailViewController.fromProfile = YES;
	musicDetailViewController.customDelegate = self;
	[self.navigationController pushViewController:musicDetailViewController animated:YES];
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
	if (_favoriteViewController) {
		[_favoriteViewController.favoriteCollectionView reloadData];
	}

	[_headerView updateFavoriteCount];
}

- (void)favoriteMgrDidFinishDownload {
	if (_favoriteViewController) {
		[_favoriteViewController.favoriteCollectionView reloadData];
	}
	[_headerView updateFavoriteCount];
}

- (int)favoriteViewControllerSelectAll:(BOOL)selected {
	int selectedCount = 0;
	NSEnumerator *enumerator = [[FavoriteMgr standard].dataSource reverseObjectEnumerator];
	for (FavoriteItem *item in enumerator) {
		item.isSelected = selected;
		if (selected) {
			selectedCount++;
		}
	}

	return selectedCount;
}

- (int)favoriteViewControllerSelectedCount {
	int selectedCount = 0;
	NSEnumerator *enumerator = [[FavoriteMgr standard].dataSource reverseObjectEnumerator];
	for (FavoriteItem *item in enumerator) {
		if (item.isSelected) {
			selectedCount++;
		}
	}

	return selectedCount;
}

- (BOOL)favoriteViewControllerDeleteMusics {
	__block BOOL retIsChanged = NO;
	[[FavoriteMgr standard] removeSelectedItemsWithCompleteBlock:^(BOOL isChanged, BOOL deletePlaying, NSArray *idArray) {
		retIsChanged = isChanged;

		if (!isChanged) {
			return ;
		}

		if (deletePlaying) {
			if ([[FavoriteMgr standard].dataSource count] > 0) {
				[self playFavoriteMusic];
			} else {
				[self pauseMusic];
			}
		}

		[_headerView updateFavoriteCount];

		[MiaAPIHelper deleteFavoritesWithIDs:idArray completeBlock:
		 ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
			 if (success) {
				 [HXAlertBanner showWithMessage:@"删除收藏成功" tap:nil];
			 } else {
				 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
				 [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
			 }
		 } timeoutBlock:^(MiaRequestItem *requestItem) {
			 [HXAlertBanner showWithMessage:@"收藏失败，网络请求超时" tap:nil];

		 }];
	}];

	return retIsChanged;
}

- (void)favoriteViewControllerPlayMusic:(NSInteger)row {
	if ([FavoriteMgr standard].dataSource.count <= 0) {
		return;
	}

	FavoriteItem *aFavoriteItem = [FavoriteMgr standard].dataSource[row];
	[self playFavoriteMusicWithoutCheckNetwork:aFavoriteItem];
}

- (void)favoriteViewControllerPauseMusic {
	[self pauseMusic];
}

#pragma mark - HXMusicDetailViewControllerDelegate
- (void)detailViewControllerDidDeleteShare {
	// 删除分享后需要从新获取分享列表
	_currentPageStart = kDefaultPageFrom;
	[_shareListModel.dataSource removeAllObjects];
	[_collectionView reloadData];
	[self requestShareList];
}

- (void)detailViewControllerDismissWithoutDelete {
	[_collectionView reloadData];
}

#pragma mark - HXShareViewControllerDelegate
- (void)shareViewControllerDidShareMusic {
	// 只有分享列表为空的时候才能在个人页面触发分享页面，所以请求之前不需要清数据
	[self requestShareList];
}

#pragma mark - SongListPlayerDataSource
- (NSInteger)songListPlayerCurrentItemIndex {
	return [FavoriteMgr standard].currentPlaying;
}

- (NSInteger)songListPlayerNextItemIndex {
	NSInteger nextIndex = [FavoriteMgr standard].currentPlaying + 1;
	if (nextIndex >= [FavoriteMgr standard].dataSource.count) {
		nextIndex = 0;
	}

	return nextIndex;
}

- (MusicItem *)songListPlayerItemAtIndex:(NSInteger)index {
	FavoriteItem *aFavoriteItem =  [FavoriteMgr standard].dataSource[index];
	return [aFavoriteItem.music copy];
}

#pragma mark - SongListPlayerDelegate
- (void)songListPlayerDidPlay {
	[_headerView setIsPlaying:YES];
}

- (void)songListPlayerDidPause {
	[_headerView setIsPlaying:NO];
}

- (void)songListPlayerDidCompletion {
	if (_playingFavorite) {
		[FavoriteMgr standard].currentPlaying++;
		[self playFavoriteMusic];
		if (_favoriteViewController) {
			[_favoriteViewController.favoriteCollectionView reloadData];
		}
	}
}

- (void)songListPlayerShouldPlayNext {
	if (_playingFavorite) {
		[FavoriteMgr standard].currentPlaying++;
		[self playFavoriteMusic];
		if (_favoriteViewController) {
			[_favoriteViewController.favoriteCollectionView reloadData];
		}
	}
}

- (void)songListPlayerShouldPlayPrevios {
	if (_playingFavorite) {
		[self playPreviosFavoriteMusic];
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
	if ([FavoriteMgr standard].dataSource.count <= 0) {
		return;
	}

	FavoriteItem *itemForPlay = [FavoriteMgr standard].dataSource[[FavoriteMgr standard].currentPlaying];

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
	for (unsigned long i = 0; i < [FavoriteMgr standard].dataSource.count; i++) {
		FavoriteItem* item = [FavoriteMgr standard].dataSource[i];
		if ([[FavoriteMgr standard] isItemCached:item]) {
			itemForPlay = item;
			[FavoriteMgr standard].currentPlaying = i;
			break;
		}
	}

	if (nil == itemForPlay) {
		NSLog(@"没有可以播放的离线歌曲");
		return;
	}

	[self playFavoriteMusicWithoutCheckNetwork:itemForPlay];
}

- (void)playPreviosFavoriteMusic {
	if ([FavoriteMgr standard].dataSource.count <= 0) {
		return;
	}
	if (([FavoriteMgr standard].currentPlaying - 1) < 0) {
		return;
	}

	[FavoriteMgr standard].currentPlaying--;

	FavoriteItem *itemForPlay = [FavoriteMgr standard].dataSource[[FavoriteMgr standard].currentPlaying];

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

	// 寻找上一首已经缓存了的歌曲
	itemForPlay = nil;
	for (long i = [FavoriteMgr standard].dataSource.count - 1; i >= 0; i--) {
		FavoriteItem* item = [FavoriteMgr standard].dataSource[i];
		if ([[FavoriteMgr standard] isItemCached:item]) {
			itemForPlay = item;
			[FavoriteMgr standard].currentPlaying = i;
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

	[_headerView setIsPlaying:YES];
	[_favoriteViewController setIsPlaying:YES];
}

- (void)pauseMusic {
	[_songListPlayer pause];
	[_headerView setIsPlaying:NO];
	[_favoriteViewController setIsPlaying:NO];
}

#pragma mark - button Actions

- (void)backButtonAction:(id)sender {
	if (_playingFavorite) {
		[_songListPlayer stop];
	}

	if (_customDelegate) {
		[_customDelegate myProfileViewControllerWillDismiss];
	}
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)settingButtonAction:(id)sender {
	NSLog(@"setting button clicked.");
	SettingViewController *vc = [[SettingViewController alloc] init];
	[self.navigationController pushViewController:vc animated:YES];
}

- (void)noShareTouchAction:(id)sender {
    HXShareViewController *shareViewController = [HXShareViewController instance];
	shareViewController.customDelegate = self;
    [self.navigationController pushViewController:shareViewController animated:YES];
}

@end
