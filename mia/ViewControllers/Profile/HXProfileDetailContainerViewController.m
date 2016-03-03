//
//  HXProfileDetailContainerViewController.m
//  mia
//
//  Created by miaios on 16/1/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXProfileDetailContainerViewController.h"
#import "HXProfileViewModel.h"
#import "HXAlertBanner.h"
#import "MiaAPIHelper.h"
#import "WebSocketMgr.h"
#import "MusicMgr.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "MJRefresh.h"
#import "UIConstants.h"
#import "UIActionSheet+BlocksKit.h"
#import "FavoriteMgr.h"
#import "HXUserSession.h"
#import "NSObject+LoginAction.h"
#import "HXMusicDetailViewController.h"

@interface HXProfileDetailContainerViewController () <
HXProfileDetailHeaderDelegate,
HXProfileShareCellDelegate
>
@end

@implementation HXProfileDetailContainerViewController {
    CGFloat _footerHeight;
    HXProfileViewModel *_viewModel;
    
	BOOL _isPlayButtonSelected;
}

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

+ (NSString *)segueIdentifier {
    return @"HXProfileDetailContainerIdentifier";
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    _footerHeight = 10.0f;
    
    _viewModel = [HXProfileViewModel instanceWithUID:_uid];
    
    __weak __typeof__(self)weakSelf = self;
    [_viewModel fetchProfileListData:^(HXProfileViewModel *viewModel) {
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf endLoad];
    } failure:^(NSString *message) {
        [HXAlertBanner showWithMessage:message tap:nil];
    }];
}

- (void)viewConfigure {
    [self addRefreshFooter];
}

#pragma mark - Setter And Getter
- (void)setShareCount:(NSInteger)shareCount {
	_shareCount = shareCount > 0 ? shareCount : 0;
}

- (void)setFavoriteCount:(NSInteger)favoriteCount {
	_favoriteCount = favoriteCount > 0 ? favoriteCount : 0;
}

#pragma mark - Private Methods
- (void)addRefreshFooter {
    MJRefreshAutoNormalFooter *refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(fetchMoreShareData)];
    [refreshFooter setTitle:@"" forState:MJRefreshStateIdle];
    [refreshFooter setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
    [refreshFooter setAutomaticallyHidden:YES];
    self.tableView.mj_footer = refreshFooter;
}

- (void)removeRefreshFooter {
    self.tableView.mj_footer = nil;
}

- (void)endLoad {
    [self.tableView.mj_footer endRefreshing];
    [self.tableView reloadData];
    
    BOOL hasData = _viewModel.dataSource.count;
    if (!hasData) {
        [self removeRefreshFooter];
        [self resizeFooter];
    }
    
    _promptView.hidden = hasData;
}

- (void)resizeFooter {
    _footer.height = SCREEN_HEIGHT;
}

- (void)fetchMoreShareData {
    [_viewModel fetchProfileListMoreData];
}

- (void)deleteShareWithIndex:(NSInteger)index sID:(NSString *)sID {
	UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:nil];
    [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
    [actionSheet bk_setDestructiveButtonWithTitle:@"删除" handler:^{
        [MiaAPIHelper deleteShareById:sID completeBlock:
         ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
             if (success) {
                 [HXAlertBanner showWithMessage:@"删除成功" tap:nil];
                 
                 [_viewModel deleteShareItemWithIndex:index];
                 
                 _shareCount--;
                 [self setShareCount:_shareCount];
                 [self endLoad];
             } else {
                 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
                 [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
             }
         } timeoutBlock:^(MiaRequestItem *requestItem) {
             [HXAlertBanner showWithMessage:@"删除失败，网络请求超时" tap:nil];
         }];
    }];
	[actionSheet showInView:self.view];
}

#pragma mark - ScrollView Delegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_delegate && [_delegate respondsToSelector:@selector(detailContainerDidScroll:scrollOffset:)]) {
        [_delegate detailContainerDidScroll:self scrollOffset:scrollView.contentOffset];
    }
}

#pragma mark - Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _viewModel.rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HXProfileShareCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HXProfileShareCell class]) forIndexPath:indexPath];
    return cell;
}

#pragma mark - Table View Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.0f;
    height = [tableView fd_heightForCellWithIdentifier:NSStringFromClass([HXProfileShareCell class]) cacheByIndexPath:indexPath configuration:
              ^(HXProfileShareCell *cell) {
                  [(HXProfileShareCell *)cell displayWithItem:_viewModel.dataSource[indexPath.row]];
              }];
    return height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self resizeFooter];
    
    HXProfileShareCell *shareCell = (HXProfileShareCell *)cell;
    [shareCell displayWithItem:_viewModel.dataSource[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HXMusicDetailViewController *detailViewController = [HXMusicDetailViewController instance];
    detailViewController.playItem = _viewModel.dataSource[indexPath.row];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - HXProfileDetailHeaderDelegate Methods
- (void)detailHeader:(HXProfileDetailHeader *)header takeAction:(HXProfileDetailHeaderAction)action {
    switch (action) {
        case HXProfileDetailHeaderActionAttention: {
            if (_delegate && [_delegate respondsToSelector:@selector(detailContainer:takeAction:)]) {
                [_delegate detailContainer:self takeAction:HXProfileDetailContainerActionShoulFollow];
            }
            break;
        }
        case HXProfileDetailHeaderActionPlay: {
            [[MusicMgr standard] setPlayList:_viewModel.dataSource hostObject:self];
            [[MusicMgr standard] playCurrent];
            break;
        }
        case HXProfileDetailHeaderActionShowFans: {
            if (_delegate && [_delegate respondsToSelector:@selector(detailContainer:takeAction:)]) {
                [_delegate detailContainer:self takeAction:HXProfileDetailContainerActionShowFans];
            }
            break;
        }
        case HXProfileDetailHeaderActionShowFollow: {
            if (_delegate && [_delegate respondsToSelector:@selector(detailContainer:takeAction:)]) {
                [_delegate detailContainer:self takeAction:HXProfileDetailContainerActionShowFollow];
            }
            break;
        }
    }
}

#pragma mark - HXProfileShareCellDelegate Methods
- (void)shareCell:(HXProfileShareCell *)cell takeAction:(HXProfileShareCellAction)action {
    NSInteger index = [self.tableView indexPathForCell:cell].row;
    ShareItem *item = _viewModel.dataSource[index];
    switch (action) {
        case HXProfileShareCellActionPlay: {
            NSInteger index = [self.tableView indexPathForCell:cell].row;
            [[MusicMgr standard] setPlayListWithItem:_viewModel.dataSource[index] hostObject:self];
            [[MusicMgr standard] playCurrent];
            
            [self.tableView reloadData];
            break;
        }
        case HXProfileShareCellActionFavorite: {
            switch ([HXUserSession share].userState) {
                case HXUserStateLogout: {
                    [self shouldLogin];
                    break;
                }
                case HXUserStateLogin: {
                    [MiaAPIHelper favoriteMusicWithShareID:item.sID
                                                isFavorite:!item.favorite
                                             completeBlock:
                     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
                         if (success) {
                             id act = userInfo[MiaAPIKey_Values][@"act"];
                             id sID = userInfo[MiaAPIKey_Values][@"id"];
                             BOOL favorite = [act intValue];
                             if ([item.sID integerValue] == [sID intValue]) {
                                 item.favorite = favorite;
                             }
                             
                             cell.favorite = favorite;
                             [HXAlertBanner showWithMessage:(favorite ? @"收藏成功" : @"取消收藏成功") tap:nil];
                             
                             if (favorite) {
                                 _favoriteCount++;
                             } else {
                                 _favoriteCount--;
                             }
                             [self setFavoriteCount:_favoriteCount];
                             
                             // 收藏操作成功后同步下收藏列表并检查下载
                             [[FavoriteMgr standard] syncFavoriteList];
                         } else {
                             id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
                             [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
                         }
                     } timeoutBlock:^(MiaRequestItem *requestItem) {
                         [HXAlertBanner showWithMessage:@"收藏失败，网络请求超时" tap:nil];
                     }];
                    break;
                }
            }
            break;
        }
    }
}

@end
