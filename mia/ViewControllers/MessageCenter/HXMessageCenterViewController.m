//
//  HXMessageCenterViewController.m
//  mia
//
//  Created by miaios on 16/1/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXMessageCenterViewController.h"
#import "HXMessageCell.h"

@interface HXMessageCenterViewController () <
HXMessageCellDelegate
>
@end

@implementation HXMessageCenterViewController

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

- (NSString *)navigationControllerIdentifier {
    return @"HXMessageCenterNavigationController";
}

- (HXStoryBoardName)storyBoardName {
    return HXStoryBoardNameMessageCenter;
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    ;
}

- (void)viewConfigure {
    ;
}

#pragma mark - Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HXMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HXMessageCell class]) forIndexPath:indexPath];
    [cell displayWithMessageModel:nil];
    return cell;
}

#pragma mark - Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - HXMessageCellDelegate Methods
- (void)messageCell:(HXMessageCell *)cell takeAction:(HXMessageCellAction)action {
    switch (action) {
        case HXMessageCellActionAvatarTaped: {
            ;
            break;
        }
    }
}

@end
