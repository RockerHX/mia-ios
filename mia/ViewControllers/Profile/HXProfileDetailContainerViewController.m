//
//  HXProfileDetailContainerViewController.m
//  mia
//
//  Created by miaios on 16/1/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXProfileDetailContainerViewController.h"
#import "HXProfileListViewModel.h"
#import "HXAlertBanner.h"
#import "UserSession.h"
#import "MiaAPIHelper.h"
#import "WebSocketMgr.h"
#import "FavoriteMgr.h"
//#import "SongListPlayer.h"
#import "UserSetting.h"
#import "PathHelper.h"
#import "MusicMgr.h"
//#import "HXMusicDetailViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "MJRefresh.h"
#import "UIConstants.h"
#import "UIActionSheet+BlocksKit.h"

@interface HXProfileDetailContainerViewController () <
HXProfileDetailHeaderDelegate,
HXProfileShareCellDelegate
//SongListPlayerDataSource,
//SongListPlayerDelegate
>
@end

@implementation HXProfileDetailContainerViewController {
    CGFloat _footerHeight;
    HXProfileListViewModel *_viewModel;
    
//    SongListPlayer *_songListPlayer;
	BOOL _isPlayButtonSelected;
}

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

+ (NSString *)segueIdentifier {
    return @"HXProfileDetailContainerIdentifier";
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    _footerHeight = 10.0f;
    
    _viewModel = [HXProfileListViewModel instanceWithUID:_uid];
    
    __weak __typeof__(self)weakSelf = self;
    [_viewModel fetchProfileListData:^(HXProfileListViewModel *viewModel) {
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf endLoad];
    } failure:^(NSString *message) {
        [HXAlertBanner showWithMessage:message tap:nil];
    }];
    
//    _songListPlayer = [[SongListPlayer alloc] initWithModelID:(long)(__bridge void *)self name:@"HXProfileViewController Song List"];
//    _songListPlayer.dataSource = self;
//    _songListPlayer.delegate = self;
}

- (void)viewConfigure {
//    _header = [[HXProfileDetailHeader alloc] initWithFrame:CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, 264.0f)];
//    _header.delegate = self;
//    _header.type = _type;
//    
//    self.tableView.contentInset = UIEdgeInsetsMake(64.0f, 0.0f, 0.0f, 0.0f);
    [self addRefreshFooter];
}

#pragma mark - Setter And Getter
- (void)setShareCount:(NSInteger)shareCount {
	_shareCount = shareCount > 0 ? shareCount : 0;
}

- (void)setFavoriteCount:(NSInteger)favoriteCount {
	_favoriteCount = favoriteCount > 0 ? favoriteCount : 0;
}

#pragma mark - Public Methods
- (void)showMessageWithAvatar:(NSString *)avatar count:(NSInteger)count {
    ;
}

- (void)stopMusic {
//	if ([_songListPlayer isPlaying]) {
//		[_songListPlayer stop];
//	}
}

#pragma mark - Private Methods
- (void)addRefreshFooter {
    MJRefreshAutoNormalFooter *refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(fetchMoreShareData)];
    [refreshFooter setTitle:@"" forState:MJRefreshStateIdle];
    [refreshFooter setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
    [refreshFooter setAutomaticallyHidden:YES];
    self.tableView.mj_footer = refreshFooter;
}

- (void)removeRefreshFooter {
    self.tableView.mj_footer = nil;
}

- (void)endLoad {
    [self.tableView.mj_footer endRefreshing];
    [self.tableView reloadData];
    
    BOOL hasData = _viewModel.dataSource.count;
    if (!hasData) {
        [self removeRefreshFooter];
        [self resizeFooter];
    }
    
    _promptView.hidden = hasData;
}

- (void)resizeFooter {
    _footer.height = SCREEN_HEIGHT;
}

- (void)fetchMoreShareData {
    [_viewModel fetchProfileListMoreData];
}

- (void)playMusic {
    [self playFavoriteMusic];
    [self.tableView reloadData];
}

- (void)deleteShareWithIndex:(NSInteger)index sID:(NSString *)sID {
	UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:nil];
    [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
    [actionSheet bk_setDestructiveButtonWithTitle:@"删除" handler:^{
        [MiaAPIHelper deleteShareById:sID completeBlock:
         ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
             if (success) {
                 [HXAlertBanner showWithMessage:@"删除成功" tap:nil];
                 
                 [_viewModel deleteShareItemWithIndex:index];
                 
                 _shareCount--;
                 [self setShareCount:_shareCount];
                 [self endLoad];
             } else {
                 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
                 [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
             }
         } timeoutBlock:^(MiaRequestItem *requestItem) {
             [HXAlertBanner showWithMessage:@"删除失败，网络请求超时" tap:nil];
         }];
    }];
	[actionSheet showInView:self.view];
}

#pragma mark - Audio operations
- (void)playFavoriteMusic {
//    if ([FavoriteMgr standard].dataSource.count <= 0) {
//        return;
//    }
//    
//    FavoriteItem *itemForPlay = [FavoriteMgr standard].dataSource[[FavoriteMgr standard].currentPlaying];
//    
//    // Wifi环境或者歌曲已经缓存，直接播放
//    if ([[WebSocketMgr standard] isWifiNetwork] || [[FavoriteMgr standard] isItemCached:itemForPlay]) {
//        [self playFavoriteMusicWithoutCheckNetwork:itemForPlay];
//        return;
//    }
//    
//    // 用户允许3G环境下播放歌曲
//    if ([UserSetting isAllowedToPlayNowWithURL:itemForPlay.music.murl]) {
//        [self playFavoriteMusicWithoutCheckNetwork:itemForPlay];
//        return;
//    }
//    
//    // 寻找下一首已经缓存了的歌曲
//    itemForPlay = nil;
//    for (unsigned long i = 0; i < [FavoriteMgr standard].dataSource.count; i++) {
//        FavoriteItem* item = [FavoriteMgr standard].dataSource[i];
//        if ([[FavoriteMgr standard] isItemCached:item]) {
//            itemForPlay = item;
//            [FavoriteMgr standard].currentPlaying = i;
//            break;
//        }
//    }
//    
//    if (nil == itemForPlay) {
//        NSLog(@"没有可以播放的离线歌曲");
//        return;
//    }
//    
//    [self playFavoriteMusicWithoutCheckNetwork:itemForPlay];
}

- (void)playPreviosFavoriteMusic {
//    if ([FavoriteMgr standard].dataSource.count <= 0) {
//        return;
//    }
//    if (([FavoriteMgr standard].currentPlaying - 1) < 0) {
//        return;
//    }
//    
//    [FavoriteMgr standard].currentPlaying--;
//    
//    FavoriteItem *itemForPlay = [FavoriteMgr standard].dataSource[[FavoriteMgr standard].currentPlaying];
//    
//    // Wifi环境或者歌曲已经缓存，直接播放
//    if ([[WebSocketMgr standard] isWifiNetwork] || [[FavoriteMgr standard] isItemCached:itemForPlay]) {
//        [self playFavoriteMusicWithoutCheckNetwork:itemForPlay];
//        return;
//    }
//    
//    // 用户允许3G环境下播放歌曲
//    if ([UserSetting isAllowedToPlayNowWithURL:itemForPlay.music.murl]) {
//        [self playFavoriteMusicWithoutCheckNetwork:itemForPlay];
//        return;
//    }
//    
//    // 寻找上一首已经缓存了的歌曲
//    itemForPlay = nil;
//    for (long i = [FavoriteMgr standard].dataSource.count - 1; i >= 0; i--) {
//        FavoriteItem* item = [FavoriteMgr standard].dataSource[i];
//        if ([[FavoriteMgr standard] isItemCached:item]) {
//            itemForPlay = item;
//            [FavoriteMgr standard].currentPlaying = i;
//            break;
//        }
//    }
//    
//    if (nil == itemForPlay) {
//        NSLog(@"没有可以播放的离线歌曲");
//        return;
//    }
//    
//    [self playFavoriteMusicWithoutCheckNetwork:itemForPlay];
}

- (void)playFavoriteMusicWithoutCheckNetwork:(FavoriteItem *)aFavoriteItem {
//    if (!aFavoriteItem) {
//        NSLog(@"FavoriteItem is nil, play was ignored.");
//        return;
//    }
//    
//    MusicItem *musicItem = [aFavoriteItem.music copy];
//    if (!musicItem.murl || !musicItem.name || !musicItem.singerName) {
//        NSLog(@"Music is nil, stop play it.");
//        return;
//    }
//    
//    if (aFavoriteItem.isCached && [[FavoriteMgr standard] isItemCached:aFavoriteItem]) {
//        musicItem.murl = [NSString stringWithFormat:@"file://%@", [PathHelper genMusicFilenameWithUrl:musicItem.murl]];
//    } else {
//        NSLog(@"收藏中播放还未下载的歌曲");
//    }
//    
//    [[MusicMgr standard] setCurrentPlayer:_songListPlayer];
//    [_songListPlayer playWithMusicItem:musicItem];
}

- (void)pauseMusic {
//    [_songListPlayer pause];
}

#pragma mark - ScrollView Delegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_delegate && [_delegate respondsToSelector:@selector(detailContainerDidScroll:scrollOffset:)]) {
        [_delegate detailContainerDidScroll:self scrollOffset:scrollView.contentOffset];
    }
}

#pragma mark - Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _viewModel.rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HXProfileShareCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HXProfileShareCell class]) forIndexPath:indexPath];
    return cell;
}

#pragma mark - Table View Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.0f;
    height = [tableView fd_heightForCellWithIdentifier:NSStringFromClass([HXProfileShareCell class]) cacheByIndexPath:indexPath configuration:
              ^(HXProfileShareCell *cell) {
                  [(HXProfileShareCell *)cell displayWithItem:_viewModel.dataSource[indexPath.row]];
              }];
    return height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self resizeFooter];
    
    HXProfileShareCell *shareCell = (HXProfileShareCell *)cell;
    [shareCell displayWithItem:_viewModel.dataSource[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_delegate && [_delegate respondsToSelector:@selector(detailContainer:takeAction:)]) {
        [_delegate detailContainer:self takeAction:HXProfileDetailContainerActionShowMusicDetail];
    }
//    HXMusicDetailViewController *musicDetailViewController = [HXMusicDetailViewController instance];
//    musicDetailViewController.sID = ((ShareItem *)_viewModel.dataSource[indexPath.row]).sID;
//    [self.navigationController pushViewController:musicDetailViewController animated:YES];
}

#pragma mark - HXProfileDetailHeaderDelegate Methods
- (void)detailHeader:(HXProfileDetailHeader *)header takeAction:(HXProfileDetailHeaderAction)action {
    switch (action) {
        case HXProfileDetailHeaderActionShowFans: {
            if (_delegate && [_delegate respondsToSelector:@selector(detailContainer:takeAction:)]) {
                [_delegate detailContainer:self takeAction:HXProfileDetailContainerActionShowFans];
            }
            break;
        }
        case HXProfileDetailHeaderActionShowFollow: {
            if (_delegate && [_delegate respondsToSelector:@selector(detailContainer:takeAction:)]) {
                [_delegate detailContainer:self takeAction:HXProfileDetailContainerActionShowFollow];
            }
            break;
        }
//        case HXProfileDetailHeaderActionShowMessage: {
//			if (_delegate && [_delegate respondsToSelector:@selector(detailContainer:takeAction:)]) {
//				[_delegate detailContainer:self takeAction:HXProfileDetailContainerActionShowMessageCenter];
//			}
//
//            break;
//        }
//        case HXProfileDetailHeaderActionTakeFollow: {
//            if (_delegate && [_delegate respondsToSelector:@selector(detailContainer:takeAction:)]) {
//                [_delegate detailContainer:self takeAction:HXProfileDetailContainerActionShoulFollow];
//            }
//            break;
//        }
    }
}

#pragma mark - HXProfileShareCellDelegate Methods
- (void)shareCell:(HXProfileShareCell *)cell takeAction:(HXProfileShareCellAction)action {
    NSInteger index = [self.tableView indexPathForCell:cell].row;
    ShareItem *item = _viewModel.dataSource[index];
    switch (action) {
        case HXProfileShareCellActionFavorite: {
            if ([[UserSession standard] isLogined]) {
                [MiaAPIHelper favoriteMusicWithShareID:item.sID
                                            isFavorite:!item.favorite
                                         completeBlock:
                 ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
                     if (success) {
                         id act = userInfo[MiaAPIKey_Values][@"act"];
                         id sID = userInfo[MiaAPIKey_Values][@"id"];
                         BOOL favorite = [act intValue];
                         if ([item.sID integerValue] == [sID intValue]) {
                             item.favorite = favorite;
                         }
                         
                         cell.favorite = favorite;
                         [HXAlertBanner showWithMessage:(favorite ? @"收藏成功" : @"取消收藏成功") tap:nil];

						 if (favorite) {
							 _favoriteCount++;
						 } else {
							 _favoriteCount--;
						 }
						 [self setFavoriteCount:_favoriteCount];

                         // 收藏操作成功后同步下收藏列表并检查下载
                         [[FavoriteMgr standard] syncFavoriteList];
                     } else {
                         id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
                         [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
                     }
                 } timeoutBlock:^(MiaRequestItem *requestItem) {
                     [HXAlertBanner showWithMessage:@"收藏失败，网络请求超时" tap:nil];
                 }];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedLoginNotification object:nil];
            }
            break;
        }
        case HXProfileShareCellActionDelete: {
			[self deleteShareWithIndex:index sID:item.sID];
            break;
        }
    }
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

//- (MusicItem *)songListPlayerItemAtIndex:(NSInteger)index {
//	if ([FavoriteMgr standard].dataSource.count <= 0) {
//		return nil;
//	}
//
//    FavoriteItem *aFavoriteItem =  [FavoriteMgr standard].dataSource[index];
//    return [aFavoriteItem.music copy];
//}

#pragma mark - SongListPlayerDelegate
- (void)songListPlayerDidPlay {
	_isPlayButtonSelected = YES;
	[self.tableView reloadData];
}

- (void)songListPlayerDidPause {
	_isPlayButtonSelected = NO;
    [self.tableView reloadData];
}

- (void)songListPlayerDidCompletion {
//    NSInteger playIndex = [FavoriteMgr standard].currentPlaying;
//    NSArray *dataSource = _viewModel.dataSource;
//    if (playIndex < dataSource.count) {
//        FavoriteItem *item = dataSource[playIndex];
//        item.isPlaying = NO;
//    }
//    [FavoriteMgr standard].currentPlaying++;
//    NSInteger selectedIndex = [FavoriteMgr standard].currentPlaying;
//    if (selectedIndex < dataSource.count) {
//        FavoriteItem *item = dataSource[selectedIndex];
//        item.isPlaying = YES;
//        
//        [FavoriteMgr standard].currentPlaying = selectedIndex;
//    }
//    [self playMusic];
}

- (void)songListPlayerShouldPlayNext {
    [FavoriteMgr standard].currentPlaying++;
    [self playFavoriteMusic];
}

- (void)songListPlayerShouldPlayPrevios {
    [self playPreviosFavoriteMusic];
}

@end
