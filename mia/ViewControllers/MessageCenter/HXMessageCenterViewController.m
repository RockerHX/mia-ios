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
#import "UITableView+FDTemplateLayoutCell.h"
#import "UIView+Frame.h"
#import "UserSession.h"

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
	[_messageModel reset];
	[self fetchMessageList];
}

- (void)fetchMoreData {
    [super fetchMoreData];
    
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
			 [[UserSession standard] clearNotify];
			 
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
	if (_messageModel.dataSource.count <= 0) {
		return nil;
	}
	
    HXMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HXMessageCell class]) forIndexPath:indexPath];
    [cell displayWithMessageItem:_messageModel.dataSource[indexPath.row]];
    return cell;
}

#pragma mark - Table View Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageItem *item = _messageModel.dataSource[indexPath.row];
    return [tableView fd_heightForCellWithIdentifier:NSStringFromClass([HXMessageCell class]) cacheByIndexPath:indexPath configuration:
            ^(HXMessageCell *cell) {
                [cell displayWithMessageItem:item];
            }];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (tableView.contentSize.height > (self.view.height - 64.0f)) {
        [self addFreshFooter];
    }
}

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
