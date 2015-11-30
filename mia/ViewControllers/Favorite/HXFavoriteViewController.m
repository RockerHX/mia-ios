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

@interface HXFavoriteViewController ()
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
    
}

#pragma mark - Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HXFavoriteCell class]) forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
