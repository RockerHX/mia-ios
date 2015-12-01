//
//  HXFavoriteEditViewController.m
//  mia
//
//  Created by miaios on 15/12/1.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXFavoriteEditViewController.h"

@interface HXFavoriteEditViewController ()
@end

@implementation HXFavoriteEditViewController

#pragma mark - View Controller Life Cycle
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initConfig];
    [self viewConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
}

- (void)viewConfig {
}

#pragma mark - Setter And Getter Methods
- (HXStoryBoardName)storyBoardName {
    return HXStoryBoardNameFavorite;
}

#pragma mark - Event Response
- (IBAction)selectAllButtonPressed {
    
}

- (IBAction)completedButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(favoriteEditViewControllerEdited:)]) {
        [_delegate favoriteEditViewControllerEdited:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    HXFavoriteCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HXFavoriteCell class]) forIndexPath:indexPath];
//    [cell displayWithItem:(_favoriteMgr.dataSource.count > indexPath.row) ? _favoriteMgr.dataSource[indexPath.row] : nil];
    return nil;
}

#pragma mark - Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
