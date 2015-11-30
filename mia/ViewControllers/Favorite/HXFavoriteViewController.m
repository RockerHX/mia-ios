//
//  HXFavoriteViewController.m
//  mia
//
//  Created by miaios on 15/11/27.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXFavoriteViewController.h"
#import "HXFavoriteCell.h"
#import "FavoriteMgr.h"
#import "HXFavoriteHeader.h"

@interface HXFavoriteViewController () <HXFavoriteHeaderDelegate>
@end

@implementation HXFavoriteViewController {
    FavoriteMgr *_favoriteMgr;
}

#pragma mark - View Controller Life Cycle
- (void)viewWillAppear:(BOOL)animated {
    [self updateFavoriteHeader];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initConfig];
    [self viewConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
    _favoriteMgr = [FavoriteMgr standard];
}

- (void)viewConfig {
    [self updateFavoriteHeader];
}

#pragma mark - Private Methods
- (void)updateFavoriteHeader {
    _header.countLabel.text = @(_favoriteMgr.dataSource.count).stringValue;
}

#pragma mark - Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_favoriteMgr favoriteCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HXFavoriteCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HXFavoriteCell class]) forIndexPath:indexPath];
    [cell displayWithItem:(_favoriteMgr.dataSource.count > indexPath.row) ? _favoriteMgr.dataSource[indexPath.row] : nil];
    return cell;
}

#pragma mark - Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - HXFavoriteHeaderDelegate Methods
- (void)favoriteHeader:(HXFavoriteHeader *)header takeAction:(HXFavoriteHeaderAction)action {
    switch (action) {
        case HXFavoriteHeaderActionPlay: {
            ;
            break;
        }
        case HXFavoriteHeaderActionPause: {
            ;
            break;
        }
        case HXFavoriteHeaderActionEdit: {
            ;
            break;
        }
    }
}

@end
