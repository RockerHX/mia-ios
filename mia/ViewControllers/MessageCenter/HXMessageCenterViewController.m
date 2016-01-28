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
	_messageModel = [[MessageModel alloc] init];
	[self requestMessageList];
}

- (void)viewConfigure {
    ;
}

#pragma mark - Private Methods
- (void)requestMessageList {
	[MiaAPIHelper getNotifyWithLastID:_messageModel.lastID
								item:kMessagePageCount
					   completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
//						   [_fansView endAllRefreshing];
						   if (success) {
							   NSArray *items = userInfo[@"v"][@"info"];
							   if ([items count] <= 0) {
//								   [_fansView checkNoDataTipsStatus];
								   return;
							   }

							   [_messageModel addItemsWithArray:items];
//							   [_fansView.collectionView reloadData];
//							   [_fansView setNoDataTipsHidden:YES];
						   } else {
//							   [_fansView checkNoDataTipsStatus];
							   id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
							   [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
						   }

					   } timeoutBlock:^(MiaRequestItem *requestItem) {
						   NSLog(@"requestFansListWithReload timeout");
//						   [_fansView checkNoDataTipsStatus];
//						   [_fansView endAllRefreshing];
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
