//
//  HXMusicDetailContainerViewController.m
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXMusicDetailContainerViewController.h"
#import "HXMusicDetailViewModel.h"
#import "HXMusicDetailCoverCell.h"
#import "HXMusicDetailSongCell.h"
#import "HXMusicDetailShareCell.h"
#import "HXMusicDetailPromptCell.h"
#import "HXMusicDetailNoCommentCell.h"
#import "HXMusicDetailCommentCell.h"
#import "ShareItem.h"
#import "MiaAPIHelper.h"
#import "HXAlertBanner.h"
#import "UserSession.h"
#import "HXInfectListView.h"
#import "InfectItem.h"
#import "LocationMgr.h"
#import "MBProgressHUDHelp.h"
#import "HXTextView.h"
#import "FavoriteMgr.h"
#import "NSString+IsNull.h"
#import "HXProfileViewController.h"
#import "WebSocketMgr.h"

@interface HXMusicDetailContainerViewController () <HXMusicDetailCoverCellDelegate, HXMusicDetailSongCellDelegate, HXMusicDetailShareCellDelegate, HXMusicDetailPromptCellDelegate, HXMusicDetailCommentCellDelegate>
@end

@implementation HXMusicDetailContainerViewController {
    HXMusicDetailViewModel 	*_viewModel;
}

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Config Methods
- (void)loadConfigure {
    ;
}

- (void)viewConfigure {
    self.tableView.scrollsToTop = YES;
}

#pragma mark - Private Methods
- (void)tableView:(UITableView *)tableView scrollTableToBottom:(BOOL)animated {
    NSInteger section = [tableView numberOfSections];
    if (section < 1) return;
    NSInteger row = [tableView numberOfRowsInSection:(section - 1)];
    if (row < 1) return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(row - 1) inSection:(section - 1)];
    
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

- (void)shouldLogin {
    ;
}

#pragma mark - Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _viewModel.rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (_viewModel) {
        HXMusicDetailRow rowType = [_viewModel.rowTypes[indexPath.row] integerValue];
        switch (rowType) {
            case HXMusicDetailRowCover: {
                cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HXMusicDetailCoverCell class]) forIndexPath:indexPath];
                [(HXMusicDetailCoverCell *)cell displayWithViewModel:_viewModel];
                break;
            }
            case HXMusicDetailRowSong: {
                cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HXMusicDetailSongCell class]) forIndexPath:indexPath];
                [(HXMusicDetailSongCell *)cell displayWithPlayItem:_viewModel.playItem];
                break;
            }
            case HXMusicDetailRowShare: {
                cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HXMusicDetailShareCell class]) forIndexPath:indexPath];
                [(HXMusicDetailShareCell *)cell displayWithShareItem:_viewModel.playItem];
                break;
            }
            case HXMusicDetailRowPrompt: {
                cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HXMusicDetailPromptCell class]) forIndexPath:indexPath];
                [(HXMusicDetailPromptCell *)cell displayWithViewModel:_viewModel];
                break;
            }
            case HXMusicDetailRowNoComment: {
                cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HXMusicDetailNoCommentCell class]) forIndexPath:indexPath];
                break;
            }
            case HXMusicDetailRowComment: {
                cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HXMusicDetailCommentCell class]) forIndexPath:indexPath];
                [(HXMusicDetailCommentCell *)cell displayWithComment:_viewModel.comments[indexPath.row - _viewModel.regularRow]];
                break;
            }
        }
    }
    return cell;
}

#pragma mark - Table View Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.0f;
    if (_viewModel) {
        HXMusicDetailRow rowType = [_viewModel.rowTypes[indexPath.row] integerValue];
        switch (rowType) {
            case HXMusicDetailRowCover: {
                height = _viewModel.frontCoverCellHeight;
                break;
            }
            case HXMusicDetailRowSong: {
                height = [tableView fd_heightForCellWithIdentifier:NSStringFromClass([HXMusicDetailSongCell class]) cacheByIndexPath:indexPath configuration:
                 ^(HXMusicDetailSongCell *cell) {
                     [cell displayWithPlayItem:_viewModel.playItem];
                }];
                break;
            }
            case HXMusicDetailRowShare: {
                height = [tableView fd_heightForCellWithIdentifier:NSStringFromClass([HXMusicDetailShareCell class]) cacheByIndexPath:indexPath configuration:
                 ^(HXMusicDetailShareCell *cell) {
                     [cell displayWithShareItem:_viewModel.playItem];
                 }];
                break;
            }
            case HXMusicDetailRowPrompt: {
                height = _viewModel.promptCellHeight;
                break;
            }
            case HXMusicDetailRowNoComment: {
                height = _viewModel.noCommentCellHeight;
                break;
            }
            case HXMusicDetailRowComment: {
                height = [tableView fd_heightForCellWithIdentifier:NSStringFromClass([HXMusicDetailCommentCell class]) cacheByIndexPath:indexPath configuration:
                 ^(HXMusicDetailCommentCell *cell) {
                     [cell displayWithComment:_viewModel.comments[indexPath.row - _viewModel.regularRow]];
                 }];
                break;
            }
        }
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.view endEditing:YES];
    if ((indexPath.row >= _viewModel.regularRow) && (_viewModel.comments.count)) {
        HXComment *comment = _viewModel.comments[indexPath.row - _viewModel.regularRow];

//		_atComment = [comment copy];
//		_editCommentView.placeholderText = [NSString stringWithFormat:@"回复%@:", _atComment.nickName];
//
//		if ([[UserSession standard] isLogined]) {
//			[_editCommentView becomeFirstResponder];
//		} else {
//			[self shouldLogin];
//		}
    }
}

#pragma mark - HXMusicDetailSongCellDelegate Methods
- (void)cellUserWouldLikeStar:(HXMusicDetailSongCell *)cell {
    if ([[UserSession standard] isLogined]) {
        ShareItem *playItem = _viewModel.playItem;
        [MiaAPIHelper favoriteMusicWithShareID:playItem.sID
                                    isFavorite:!playItem.favorite
                                 completeBlock:
         ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
             if (success) {
                 id act = userInfo[MiaAPIKey_Values][@"act"];
                 id sID = userInfo[MiaAPIKey_Values][@"id"];
                 BOOL favorite = [act intValue];
                 if ([playItem.sID integerValue] == [sID intValue]) {
                     playItem.favorite = favorite;
                     [cell updateStatStateWithFavorite:favorite];
                 }
                 [HXAlertBanner showWithMessage:(favorite ? @"收藏成功" : @"取消收藏成功") tap:nil];

				 // 收藏操作成功后同步下收藏列表并检查下载
				 [[FavoriteMgr standard] syncFavoriteList];
             } else {
                 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
                 [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
             }
         } timeoutBlock:^(MiaRequestItem *requestItem) {
             [HXAlertBanner showWithMessage:@"收藏失败，网络请求超时" tap:nil];
         }];
    } else {
        [self shouldLogin];
    }
}

#pragma mark - HXMusicDetailShareCellDelegate Methods
- (void)cellUserWouldLikeSeeSharerInfo:(HXMusicDetailShareCell *)cell {
    ShareItem *playItem = _viewModel.playItem;

	HXProfileViewController *profileViewController = [HXProfileViewController instance];
	profileViewController.uid = playItem.uID;
	[self.navigationController pushViewController:profileViewController animated:YES];
}

#pragma mark - HXMusicDetailPromptCellDelegate Methods
- (void)promptCell:(HXMusicDetailPromptCell *)cell takeAction:(HXMusicDetailPromptCellAction)action {
    switch (action) {
        case HXMusicDetailPromptCellActionInfect: {
            if ([UserSession standard].state) {
                // 传播出去不需要切换歌曲，需要记录下传播的状态和上报服务器
                [MiaAPIHelper InfectMusicWithLatitude:[[LocationMgr standard] currentCoordinate].latitude
                                            longitude:[[LocationMgr standard] currentCoordinate].longitude
                                              address:[[LocationMgr standard] currentAddress]
                                                 spID:_viewModel.playItem.spID
                                        completeBlock:
                 ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
                     if (success) {
                         
                         int isInfected = [userInfo[MiaAPIKey_Values][@"data"][@"isInfected"] intValue];
                         int infectTotal = [userInfo[MiaAPIKey_Values][@"data"][@"infectTotal"] intValue];
                         NSArray *infectArray = userInfo[MiaAPIKey_Values][@"data"][@"infectList"];
                         NSString *spID = [userInfo[MiaAPIKey_Values][@"data"][@"spID"] stringValue];
                         
                         if ([spID isEqualToString:_viewModel.playItem.spID]) {
                             _viewModel.playItem.infectTotal = infectTotal;
                             [_viewModel.playItem parseInfectUsersFromJsonArray:infectArray];
                             _viewModel.playItem.isInfected = isInfected;
                         }
                         [HXAlertBanner showWithMessage:@"妙推成功" tap:nil];
//                         [self loadDetailData];
                     } else {
                         id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
                         [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
                     }
                 } timeoutBlock:^(MiaRequestItem *requestItem) {
                     _viewModel.playItem.isInfected = YES;
                     [HXAlertBanner showWithMessage:@"妙推失败，网络请求超时" tap:nil];
                 }];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedLoginNotification object:nil];
            }
            break;
        }
        case HXMusicDetailPromptCellActionShowInfecter: {
            [HXInfectListView showWithSharerID:_viewModel.playItem.sID taped:^(id item, NSInteger index) {
                InfectItem *selectedItem = item;
                
                HXProfileViewController *profileViewController = [HXProfileViewController instance];
                profileViewController.uid = selectedItem.uID;
                [self.navigationController pushViewController:profileViewController animated:YES];
            }];
            break;
        }
    }
}

#pragma mark - HXMusicDetailCommentCellDelegate Methods
- (void)commentCellAvatarTaped:(HXMusicDetailCommentCell *)cell {
    NSInteger index = [self.tableView indexPathForCell:cell].row;
    HXComment *comment = _viewModel.comments[index - _viewModel.regularRow];
    HXProfileViewController *profileViewController = [HXProfileViewController instance];
    profileViewController.uid = comment.uid;
    [self.navigationController pushViewController:profileViewController animated:YES];
}

@end
