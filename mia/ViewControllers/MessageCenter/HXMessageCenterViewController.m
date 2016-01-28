//
//  HXMessageCenterViewController.m
//  mia
//
//  Created by miaios on 16/1/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXMessageCenterViewController.h"
#import "HXMessageCell.h"
#import "MessageModel.h"
#import "MiaAPIHelper.h"
#import "HXAlertBanner.h"

static const long kMessagePageCount = 10;

@interface HXMessageCenterViewController () <
HXMessageCellDelegate
>
@end

@implementation HXMessageCenterViewController {
	MessageModel 			*_messageModel;
}

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSString *)navigationControllerIdentifier {
    return @"HXMessageCenterNavigationController";
}

- (HXStoryBoardName)storyBoardName {
    return HXStoryBoardNameMessageCenter;
}

#pragma mark - Parent Methods
- (void)loadConfigure {
    [super loadConfigure];
    
    _messageModel = [[MessageModel alloc] init];
}

- (void)viewConfigure {
    [super viewConfigure];
}

- (void)fetchNewData {
    [super fetchNewData];
    
    [self fetchMessageList];
}

- (void)endLoad {
    [super endLoad];
    
    [self.tableView reloadData];
}

#pragma mark - Private Methods
- (void)fetchMessageList {
	[MiaAPIHelper getNotifyWithLastID:_messageModel.lastID
								item:kMessagePageCount
                        completeBlock:
     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
        if (success) {
           NSArray *items = userInfo[@"v"][@"info"];
           if ([items count] > 0) {
               [_messageModel addItemsWithArray:items];
           }
           
           [self endLoad];
        } else {
           [self endLoad];
           
           id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
           [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
        }
     } timeoutBlock:^(MiaRequestItem *requestItem) {
        [self endLoad];
        NSLog(@"requestFansListWithReload timeout");
     }];
}

#pragma mark - Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _messageModel.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HXMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HXMessageCell class]) forIndexPath:indexPath];
    [cell displayWithMessageItem:_messageModel.dataSource[indexPath.row]];
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
