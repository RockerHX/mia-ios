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
#import "FavoriteMgr.h"
#import "MusicMgr.h"
#import "MiaAPIHelper.h"
#import "HXAlertBanner.h"

@interface HXFavoriteContainerViewController () <
HXFavoriteHeaderDelegate,
FavoriteMgrDelegate
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

#pragma mark - Configure Methods
- (void)loadConfigure {
    _playIndex = -1;
    _favoriteLists = [FavoriteMgr standard].dataSource.mutableCopy;
    [FavoriteMgr standard].customDelegate = self;
}

- (void)viewConfigure {
    ;
}

#pragma mark - Private Methods
- (void)fetchUserFavoriteData {
    [[FavoriteMgr standard] syncFavoriteList];
}

- (NSArray<MusicItem *> *)musicList {
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:_favoriteLists.count];
    for (FavoriteItem *item in _favoriteLists) {
        [list addObject:item.music];
    }
    return list.copy;
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
             [HXAlertBanner showWithMessage:@"取消收藏成功！" tap:nil];
             [[FavoriteMgr standard] removeSelectedItem:selectedItem];
             
             [self fetchUserFavoriteData];
         } else {
             NSString *error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
             [HXAlertBanner showWithMessage:error tap:nil];
         }
     } timeoutBlock:^(MiaRequestItem *requestItem) {
         [HXAlertBanner showWithMessage:@"取消收藏失败，网络请求超时!" tap:nil];
     }];
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
        ;
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
    
//    [[MusicMgr standard] setPlayList:[self musicList] hostObject:self];
//    [[MusicMgr standard] playWithIndex:indexPath.row];
}

#pragma mark - HXFavoriteHeaderDelegate Methods
- (void)favoriteHeader:(HXFavoriteHeader *)header takeAction:(HXFavoriteHeaderAction)action {
    switch (action) {
        case HXFavoriteHeaderActionShuffle: {
            ;
            break;
        }
        case HXFavoriteHeaderActionEdit: {
            ;
            break;
        }
    }
}

#pragma mark - FavoriteMgrDelegate Methods
- (void)favoriteMgrDidFinishSync {
    _favoriteLists = [FavoriteMgr standard].dataSource.mutableCopy;
    [self.tableView reloadData];
}

@end
