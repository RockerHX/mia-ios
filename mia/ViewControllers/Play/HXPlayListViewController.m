//
//  HXPlayListViewController.m
//  mia
//
//  Created by miaios on 16/2/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXPlayListViewController.h"
#import "HXPlayListCell.h"

@interface HXPlayListViewController ()

@end

@implementation HXPlayListViewController

#pragma mark - Class Methods
+ (HXStoryBoardName)storyBoardName {
    return HXStoryBoardNamePlay;
}

#pragma mark - View Controller Lift Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    ;
}

- (void)viewConfigure {
    ;
}

#pragma mark - Private Methods

#pragma mark - Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _musicList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HXPlayListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HXPlayListCell class]) forIndexPath:indexPath];
    return cell;
}

#pragma mark - Table View Delegate Methods
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    HXPlayListCell *listCell = (HXPlayListCell *)cell;
    [listCell displayWithMusicList:_musicList index:indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
