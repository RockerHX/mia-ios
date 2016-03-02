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

@interface HXFavoriteEditContainerViewController ()

@end

@implementation HXFavoriteEditContainerViewController {
    NSMutableArray<FavoriteItem *> *_favoriteLists;
}

#pragma mark - View Controller Lift Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    _favoriteLists = [FavoriteMgr standard].dataSource.mutableCopy;
}

- (void)viewConfigure {
    ;
}

#pragma mark - Property
- (void)setSelectAll:(BOOL)selectAll {
    _selectAll = selectAll;
    
    
#warning Eden
    [_favoriteLists enumerateObjectsUsingBlock:^(FavoriteItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.isSelected = selectAll;
    }];
    [self.tableView reloadData];
}

#pragma mark - Public Methods
- (void)deleteAction {
    [[FavoriteMgr standard] removeSelectedItemsWithCompleteBlock:^(BOOL isChanged, BOOL deletePlaying, NSArray *idArray) {
        [self.tableView reloadData];
    }];
}

#pragma mark - Private Methods
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
