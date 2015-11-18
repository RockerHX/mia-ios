//
//  HXCardDetailView.m
//  mia
//
//  Created by miaios on 15/11/18.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXCardDetailView.h"
#import "HXMusicDetailViewModel.h"
#import "HXMusicDetailCoverCell.h"
#import "HXMusicDetailShareCell.h"
#import "HXMusicDetailInfectCell.h"
#import "HXMusicDetailNoCommentCell.h"
#import "HXMusicDetailCommentCell.h"

@implementation HXCardDetailView {
    HXMusicDetailViewModel *_viewModel;
}

#pragma mark - Init Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initConfig];
    [self viewConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
    NSString *HXMusicDetailCoverCellName = NSStringFromClass([HXMusicDetailCoverCell class]);
    [_tableView registerNib:[UINib nibWithNibName:HXMusicDetailCoverCellName bundle:nil] forCellReuseIdentifier:HXMusicDetailCoverCellName];
    
    NSString *HXMusicDetailShareCellName = NSStringFromClass([HXMusicDetailCoverCell class]);
    [_tableView registerNib:[UINib nibWithNibName:HXMusicDetailShareCellName bundle:nil] forCellReuseIdentifier:HXMusicDetailShareCellName];
    
    NSString *HXMusicDetailInfectCellName = NSStringFromClass([HXMusicDetailCoverCell class]);
    [_tableView registerNib:[UINib nibWithNibName:HXMusicDetailInfectCellName bundle:nil] forCellReuseIdentifier:HXMusicDetailInfectCellName];
    
    NSString *HXMusicDetailNoCommentCellName = NSStringFromClass([HXMusicDetailCoverCell class]);
    [_tableView registerNib:[UINib nibWithNibName:HXMusicDetailNoCommentCellName bundle:nil] forCellReuseIdentifier:HXMusicDetailNoCommentCellName];
    
    NSString *HXMusicDetailCommentCellName = NSStringFromClass([HXMusicDetailCoverCell class]);
    [_tableView registerNib:[UINib nibWithNibName:HXMusicDetailCommentCellName bundle:nil] forCellReuseIdentifier:HXMusicDetailCommentCellName];
}

- (void)viewConfig {
    
}

#pragma mark - Public Methods
- (void)displayWithViewModel:(HXMusicDetailViewModel *)viewModel {
    _viewModel = viewModel;
    [_tableView reloadData];
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
//                _coverCell = (HXMusicDetailCoverCell *)cell;
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
//    if ((indexPath.row >= _viewModel.regularRow) && (_viewModel.comments.count)) {
//        HXComment *comment = _viewModel.comments[indexPath.row - _viewModel.regularRow];
//        GuestProfileViewController *viewController = [[GuestProfileViewController alloc] initWitUID:comment.uid nickName:comment.nickName];
//        [self.navigationController pushViewController:viewController animated:YES];
//    }
}

@end
