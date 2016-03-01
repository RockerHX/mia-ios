//
//  HXListViewController.m
//  TipTop-User
//
//  Created by ShiCang on 15/10/21.
//  Copyright © 2015年 Outsourcing. All rights reserved.
//

#import "HXListViewController.h"
#import "MJRefresh.h"

@interface HXListViewController ()
@end

@implementation HXListViewController

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Config Methods
- (void)loadConfigure {
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(fetchNewData)];
    if (_hasFooter) {
        [self addFreshFooter];
    }
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)viewConfigure {}

#pragma mark - Public Methods
- (void)fetchNewData {}
- (void)fetchMoreData {}

- (void)endLoad {
    [self.tableView.mj_header endRefreshing];
}

- (void)addFreshFooter {
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(fetchMoreData)];
}

@end
