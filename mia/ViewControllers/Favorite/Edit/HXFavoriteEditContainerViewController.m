//
//  HXFavoriteEditContainerViewController.m
//  mia
//
//  Created by miaios on 16/3/2.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXFavoriteEditContainerViewController.h"
#import "HXFavoriteEditCell.h"
#import "FavoriteMgr.h"
#import "MusicMgr.h"
#import "MiaAPIHelper.h"
#import "HXAlertBanner.h"

@interface HXFavoriteEditContainerViewController ()

@end

@implementation HXFavoriteEditContainerViewController {
    NSArray<FavoriteItem *> *_favoriteLists;
}

#pragma mark - View Controller Lift Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    [self syncFavoriteList];
}

- (void)viewConfigure {
    ;
}

#pragma mark - Property
- (void)setSelectAll:(BOOL)selectAll {
    _selectAll = selectAll;
    
    [_favoriteLists enumerateObjectsUsingBlock:^(FavoriteItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.isSelected = selectAll;
    }];
    [self.tableView reloadData];
}

#pragma mark - Public Methods
- (void)deleteAction {
    [[FavoriteMgr standard] removeSelectedItemsWithCompleteBlock:^(BOOL isChanged, BOOL deletePlaying, NSArray *idArray) {
		if (!isChanged) {
			return ;
		}

		if (deletePlaying) {
			if ([[FavoriteMgr standard].dataSource count] > 0) {
				[[MusicMgr standard] playNext];
			} else {
				[[MusicMgr standard] stop];
			}
		}

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
        
        [self syncFavoriteList];
        [self.tableView reloadData];
    }];
}

#pragma mark - Private Methods
- (void)syncFavoriteList {
    _favoriteLists = [FavoriteMgr standard].dataSource.copy;
}

- (NSMutableArray *)resetStateList:(BOOL)all {
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:_favoriteLists.count];
    [_favoriteLists enumerateObjectsUsingBlock:^(FavoriteItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [list addObject:@(all)];
    }];
    return [list mutableCopy];
}

#pragma mark - Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _favoriteLists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HXFavoriteEditCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HXFavoriteEditCell class]) forIndexPath:indexPath];
    return cell;
}

#pragma mark - Table View Delegate Methods
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    HXFavoriteEditCell *editCell = (HXFavoriteEditCell *)cell;
    [editCell displayWithItem:_favoriteLists[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FavoriteItem *item = _favoriteLists[indexPath.row];
    item.isSelected = !item.isSelected;
    
    [tableView reloadData];
}

@end
