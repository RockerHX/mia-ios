//
//  HXMusicDetailViewController.m
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXMusicDetailViewController.h"
#import "HXMusicDetailViewModel.h"
#import "HXMusicDetailCoverCell.h"
#import "HXMusicDetailSongCell.h"
#import "HXMusicDetailShareCell.h"
#import "HXMusicDetailInfectCell.h"
#import "HXMusicDetailPromptCell.h"
#import "HXMusicDetailNoCommentCell.h"
#import "HXMusicDetailCommentCell.h"
#import "ShareItem.h"
#import "UIActionSheet+Blocks.h"
#import "MiaAPIHelper.h"
#import "HXAlertBanner.h"
#import "LoginViewController.h"
#import "UserSession.h"
#import "HXInfectUserListView.h"
#import "ProfileViewController.h"
#import "InfectItem.h"
#import "LocationMgr.h"

@interface HXMusicDetailViewController () <HXMusicDetailCoverCellDelegate, HXMusicDetailSongCellDelegate, HXMusicDetailShareCellDelegate, HXMusicDetailInfectCellDelegate>
@end

@implementation HXMusicDetailViewController {
    HXMusicDetailViewModel *_viewModel;
}

#pragma mark - View Controller Life Cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
	[self reportViews];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];

#warning @andy 页面关闭的时候需要停止音乐播放
	//[_detailHeaderView stopMusic];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initConfig];
    [self viewConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
    _viewModel = [[HXMusicDetailViewModel alloc] initWithItem:_playItem];
    
    __weak __typeof__(self)weakSelf = self;
    [_viewModel requestComments:^(BOOL success) {
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf.tableView reloadData];
    }];
}

- (void)viewConfig {
    [self refresh];
}

#pragma mark - Event Response
- (IBAction)moreButtonPressed {
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"取消" action:^{
        NSLog(@"cancel");
    }];
    
    RIButtonItem *reportItem = [RIButtonItem itemWithLabel:@"举报" action:^{
        [MiaAPIHelper reportShareById:_playItem.sID completeBlock:
         ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
             if (success) {
                 [HXAlertBanner showWithMessage:@"举报成功" tap:nil];
             } else {
                 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
                 [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"举报失败:%@", error] tap:nil];
             }
         } timeoutBlock:^(MiaRequestItem *requestItem) {
             [HXAlertBanner showWithMessage:@"举报失败，网络请求超时" tap:nil];
         }];
    }];
    
    RIButtonItem *deleteItem = [RIButtonItem itemWithLabel:@"删除" action:^{
        [MiaAPIHelper deleteShareById:_playItem.sID completeBlock:
         ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
             if (success) {
                 [HXAlertBanner showWithMessage:@"删除成功" tap:nil];
                 [self.navigationController popViewControllerAnimated:YES];

                 if (_customDelegate) {
                     [_customDelegate detailViewControllerDidDeleteShare];
                 }
             } else {
                 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
                 [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"删除失败:%@", error] tap:nil];
             }
         } timeoutBlock:^(MiaRequestItem *requestItem) {
             [HXAlertBanner showWithMessage:@"删除失败，网络请求超时" tap:nil];
         }];
        
    }];
    
    UIActionSheet *aActionSheet = nil;
    if (_fromProfile) {
        aActionSheet = [[UIActionSheet alloc] initWithTitle:@"更多操作"
                                           cancelButtonItem:cancelItem
                                      destructiveButtonItem:reportItem
                                           otherButtonItems:deleteItem, nil];
    } else {
        aActionSheet = [[UIActionSheet alloc] initWithTitle:@"更多操作"
                                           cancelButtonItem:cancelItem
                                      destructiveButtonItem:reportItem
                                           otherButtonItems:nil];
    }
    
    [aActionSheet showInView:self.view];
}

- (IBAction)commentButtonPressed {
    
}

#pragma mark - Private Methods
- (void)refresh {
//    [_detailView refreshWithItem:_playItem];
}

- (void)reportViews {
	[MiaAPIHelper viewShareWithLatitude:[[LocationMgr standard] currentCoordinate].latitude
							  longitude:[[LocationMgr standard] currentCoordinate].longitude
								address:[[LocationMgr standard] currentAddress]
								   spID:_playItem.spID
						  completeBlock:
	 ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
		 if (success) {
#warning @andy 服务器需要返回最新的views数字，客户端需要更新下
		 }
	 } timeoutBlock:^(MiaRequestItem *requestItem) {
		 NSLog(@"views share timeout");
	 }];
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
            case HXMusicDetailRowInfect: {
                cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HXMusicDetailInfectCell class]) forIndexPath:indexPath];
                [(HXMusicDetailInfectCell *)cell displayWithViewModel:_viewModel];
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
            case HXMusicDetailRowInfect: {
                height = _viewModel.infectCellHeight;
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
             } else {
                 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
                 [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"收藏失败:%@", error] tap:nil];
             }
         } timeoutBlock:^(MiaRequestItem *requestItem) {
             [HXAlertBanner showWithMessage:@"收藏失败，网络请求超时" tap:nil];
         }];
    } else {
        LoginViewController *vc = [[LoginViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - HXMusicDetailShareCellDelegate Methods
- (void)cellUserWouldLikeSeeSharerInfo:(HXMusicDetailShareCell *)cell {
    ShareItem *playItem = _viewModel.playItem;
    ProfileViewController *vc = [[ProfileViewController alloc] initWitUID:playItem.uID
                                                                 nickName:playItem.sNick
                                                              isMyProfile:NO];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - HXMusicDetailInfectCellDelegate Methods
- (void)cellUserWouldLikeShowInfectList:(HXMusicDetailInfectCell *)cell {
    [HXInfectUserListView showWithSharerID:_viewModel.playItem.sID taped:^(id item, NSInteger index) {
        InfectItem *selectedItem = item;
        ProfileViewController *vc = [[ProfileViewController alloc] initWitUID:selectedItem.uID
                                                                     nickName:selectedItem.nick
                                                                  isMyProfile:NO];
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

@end
