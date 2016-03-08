//
//  HXFavoriteContainerViewController.m
//  mia
//
//  Created by miaios on 16/2/22.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXFavoriteContainerViewController.h"
#import "HXFavoriteHeader.h"
#import "HXFavoriteCell.h"
#import "MusicMgr.h"
#import "MiaAPIHelper.h"
#import "HXAlertBanner.h"
#import "HXFavoriteEditViewController.h"

@interface HXFavoriteContainerViewController () <
HXFavoriteHeaderDelegate,
FavoriteMgrDelegate,
HXFavoriteEditViewControllerDelegate
>
@end

@implementation HXFavoriteContainerViewController {
    NSInteger _playIndex;
    NSMutableArray *_favoriteLists;
}

#pragma mark - View Controller Lift Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MusicMgrNotificationPlayerEvent object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self dataSysnc];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationPlayerEvent:) name:MusicMgrNotificationPlayerEvent object:nil];
    
    _playIndex = -1;
    _favoriteLists = [FavoriteMgr standard].dataSource.mutableCopy;
    _header.favoriteCount = _favoriteLists.count;
    [FavoriteMgr standard].customDelegate = self;

	[[FavoriteMgr standard] syncFavoriteList];
}

- (void)viewConfigure {
    ;
}

#pragma mark - Private Methods
- (void)fetchUserFavoriteData {
    [[FavoriteMgr standard] syncFavoriteList];
}

- (void)cancelFavoriteItemAtIndex:(NSInteger)index {
    FavoriteItem *selectedItem = _favoriteLists[index];
    NSString *sID = selectedItem.sID;
    if (selectedItem.isPlaying) {
//        [self songListPlayerDidCompletion];
    }
    
    [MiaAPIHelper deleteFavoritesWithIDs:@[sID] completeBlock:
     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
         if (success) {
             [HXAlertBanner showWithMessage:@"取消收藏成功" tap:nil];
             [[FavoriteMgr standard] removeSelectedItem:selectedItem];
             
             [self fetchUserFavoriteData];
         } else {
             NSString *error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
             [HXAlertBanner showWithMessage:error tap:nil];
         }
     } timeoutBlock:^(MiaRequestItem *requestItem) {
         [HXAlertBanner showWithMessage:@"取消收藏失败，网络请求超时" tap:nil];
     }];
}

- (void)dataSysnc {
    _favoriteLists = [FavoriteMgr standard].dataSource.mutableCopy;
    
    _header.favoriteCount = _favoriteLists.count;
    self.view.hidden = !_favoriteLists.count;
    [self.tableView reloadData];
}

- (NSArray *)shareList {
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:_favoriteLists.count];
    for (FavoriteItem *item in _favoriteLists) {
        [list addObject:item.shareItem];
    }
    return [list copy];
}

- (NSInteger)playIndexBySID:(NSString *)sid {
    for (FavoriteItem *item in _favoriteLists) {
        if ([item.shareItem.sID isEqualToString:sid]) {
            return [_favoriteLists indexOfObject:item];
        }
    }
    return -1;
}

#pragma mark - Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _favoriteLists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HXFavoriteCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HXFavoriteCell class]) forIndexPath:indexPath];
    return cell;
}

#pragma mark - Table View Delegate Methods
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    HXFavoriteCell *favoriteCell = (HXFavoriteCell *)cell;
    [favoriteCell displayWithFavoriteList:_favoriteLists.copy index:indexPath.row selected:(indexPath.row == _playIndex)];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak __typeof__(self)weakSelf = self;
    UITableViewRowAction *shareAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"分享" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        __strong __typeof__(self)strongSelf = weakSelf;
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(containerShouldShare:item:)]) {
            [strongSelf.delegate containerShouldShare:strongSelf item:strongSelf->_favoriteLists[indexPath.row]];
        }
    }];
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf cancelFavoriteItemAtIndex:indexPath.row];
    }];
    return @[deleteAction, shareAction];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _playIndex = indexPath.row;
    [tableView reloadData];
    
    MusicMgr *musicMgr = [MusicMgr standard];
    [musicMgr setPlayList:[self shareList] hostObject:self];
    [musicMgr playWithIndex:indexPath.row];
}

#pragma mark - HXFavoriteHeaderDelegate Methods
- (void)favoriteHeader:(HXFavoriteHeader *)header takeAction:(HXFavoriteHeaderAction)action {
    switch (action) {
        case HXFavoriteHeaderActionShuffle: {
            MusicMgr *musicMgr = [MusicMgr standard];
            [musicMgr setPlayList:[self shareList] hostObject:self];
            musicMgr.isShufflePlay = YES;
            [musicMgr playNext];
            break;
        }
        case HXFavoriteHeaderActionEdit: {
            UINavigationController *editNavigationController = [HXFavoriteEditViewController navigationControllerInstance];
            HXFavoriteEditViewController *editViewController = editNavigationController.viewControllers.firstObject;
            editViewController.delegate = self;
            [self presentViewController:editNavigationController animated:YES completion:nil];
            break;
        }
    }
}

#pragma mark - FavoriteMgrDelegate Methods
- (void)favoriteMgrDidFinishSync {
    [self dataSysnc];
}

- (void)favoriteMgrDidFinishDownload {
    [self dataSysnc];
}

#pragma mark - HXFavoriteEditViewControllerDelegate Methods
- (void)editFinish:(HXFavoriteEditViewController *)editViewController {
    [self dataSysnc];
}

#pragma mark - Notification Methods
- (void)notificationPlayerEvent:(NSNotification *)notification {
    NSString *sID = notification.userInfo[MusicMgrNotificationKey_sID];
    
    if ([[MusicMgr standard] isCurrentHostObject:self]) {
        _playIndex = [self playIndexBySID:sID];
        [self.tableView reloadData];
    }
}

@end
