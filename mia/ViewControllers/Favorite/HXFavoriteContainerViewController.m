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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _playIndex = indexPath.row;
    [tableView reloadData];
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
