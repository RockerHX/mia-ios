//
//  HXProfileDetailContainerViewController.m
//  mia
//
//  Created by miaios on 16/1/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXProfileDetailContainerViewController.h"
#import "HXProfileListViewModel.h"
#import "HXAlertBanner.h"
#import "UserSession.h"
#import "MiaAPIHelper.h"
#import "WebSocketMgr.h"
#import "HXProfileSongActionCell.h"
#import "HXProfileSongCell.h"

@interface HXProfileDetailContainerViewController () <
HXProfileDetailHeaderDelegate,
HXProfileSegmentViewDelegate,
HXProfileShareCellDelegate
>
@end

@implementation HXProfileDetailContainerViewController {
    CGFloat _footerHeight;
    HXProfileSegmentView *_segmentView;
    HXProfileListViewModel *_viewModel;
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
    
    _viewModel = [HXProfileListViewModel instanceWithUID:_uid];
    
    __weak __typeof__(self)weakSelf = self;
    [_viewModel fetchProfileListData:^(HXProfileListViewModel *viewModel) {
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf endLoad];
    } failure:^(NSString *message) {
        [HXAlertBanner showWithMessage:message tap:nil];
    }];
}

- (void)viewConfigure {
    _header = [[HXProfileDetailHeader alloc] initWithFrame:CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, ((SCREEN_WIDTH/375.0f) * 264.0f))];
    _header.delegate = self;
    _header.type = _type;
    
    self.tableView.contentInset = UIEdgeInsetsMake(64.0f, 0.0f, 0.0f, 0.0f);
    self.tableView.tableHeaderView = _header;
}

#pragma mark - Private Methods
- (HXProfileSegmentView *)segmentView {
    if (!_segmentView) {
        _segmentView = [HXProfileSegmentView instanceWithDelegate:self];
    }
    return _segmentView;
}

- (void)endLoad {
    [self.tableView reloadData];
    
    _segmentView.shareItemView.countLabel.text = @(_viewModel.shareCount).stringValue;
}

#pragma mark - ScrollView Delegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_footerHeight <= _header.height) {
        if (_delegate && [_delegate respondsToSelector:@selector(detailContainerDidScroll:scrollOffset:)]) {
            [_delegate detailContainerDidScroll:self scrollOffset:scrollView.contentOffset];
        }
    }
}

#pragma mark - Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _viewModel.rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    switch (_segmentView.itemType) {
        case HXProfileSegmentItemTypeShare: {
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HXProfileShareCell class]) forIndexPath:indexPath];
            [(HXProfileShareCell *)cell displayWithItem:_viewModel.dataSource[indexPath.row]];
            [(HXProfileShareCell *)cell deleteButton].hidden = !_type;
            break;
        }
        case HXProfileSegmentItemTypeFavorite: {
            HXProfileSongRowType rowType = [_viewModel.rowTypes[indexPath.row] integerValue];
            switch (rowType) {
                case HXProfileSongRowTypeSongAction: {
                    cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HXProfileSongActionCell class]) forIndexPath:indexPath];
                    break;
                }
                case HXProfileSongRowTypeSong: {
                    cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HXProfileSongCell class]) forIndexPath:indexPath];
                    break;
                }
            }
            break;
        }
    }
    return cell;
}

#pragma mark - Table View Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return _type ? _viewModel.segmentHeight : 0.0f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return _type ? [self segmentView] : nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.0f;
    switch (_segmentView.itemType) {
        case HXProfileSegmentItemTypeShare: {
            height = _viewModel.shareCellHeight;
            break;
        }
        case HXProfileSegmentItemTypeFavorite: {
            height = _viewModel.favoriteHeight;
            break;
        }
    }
    return height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"$$$$$$$$$$$$: %f", tableView.tableHeaderView.height);
    _footerHeight = (SCREEN_HEIGHT + self.tableView.tableHeaderView.height + 64.0f) - tableView.contentSize.height;
//    NSLog(@"YYYYYYYYYYYY: %f", _footerHeight);
    _footer.height = ((_footerHeight > 0) ? _footerHeight : 10.0f);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - HXProfileDetailHeaderDelegate Methods
- (void)detailHeader:(HXProfileDetailHeader *)header takeAction:(HXProfileDetailHeaderAction)action {
    switch (action) {
        case HXProfileDetailHeaderActionShowFans: {
            if (_delegate && [_delegate respondsToSelector:@selector(detailContainerWouldLikeShowFans:)]) {
                [_delegate detailContainerWouldLikeShowFans:self];
            }
            break;
        }
        case HXProfileDetailHeaderActionShowFollow: {
            if (_delegate && [_delegate respondsToSelector:@selector(detailContainerWouldLikeShowFollow:)]) {
                [_delegate detailContainerWouldLikeShowFollow:self];
            }
            break;
        }
        case HXProfileDetailHeaderActionTakeFollow: {
            ;
            break;
        }
    }
}

#pragma mark - HXProfileSegmentViewDelegate Methods
- (void)segmentView:(HXProfileSegmentView *)segmentView selectedType:(HXProfileSegmentItemType)type {
    _viewModel.itemType = type;
}

#pragma mark - HXProfileShareCellDelegate Methods
- (void)shareCell:(HXProfileShareCell *)cell takeAction:(HXProfileShareCellAction)action {
    NSInteger index = [self.tableView indexPathForCell:cell].row;
    ShareItem *item = _viewModel.dataSource[index];
    switch (action) {
        case HXProfileShareCellActionFavorite: {
            if ([[UserSession standard] isLogined]) {
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
                         
                         // 收藏操作成功后同步下收藏列表并检查下载
//                         [[FavoriteMgr standard] syncFavoriteList];
                     } else {
                         id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
                         [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
                     }
                 } timeoutBlock:^(MiaRequestItem *requestItem) {
                     [HXAlertBanner showWithMessage:@"收藏失败，网络请求超时" tap:nil];
                 }];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedLoginNotification object:nil];
            }
            break;
        }
        case HXProfileShareCellActionDelete: {
            [MiaAPIHelper deleteShareById:item.sID completeBlock:
             ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
                 if (success) {
                     [HXAlertBanner showWithMessage:@"删除成功" tap:nil];
                     
                     [_viewModel deleteShareItemWithIndex:index];
                     [self.tableView reloadData];
                 } else {
                     id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
                     [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
                 }
             } timeoutBlock:^(MiaRequestItem *requestItem) {
                 [HXAlertBanner showWithMessage:@"删除失败，网络请求超时" tap:nil];
             }];
            break;
        }
    }
}

@end
