//
//  UserListView.h
//  mia
//
//  Created by linyehui on 2015/09/29.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserCollectionViewCell.h"

@class UserListModel;
@class UserItem;

typedef NS_ENUM(NSUInteger, UserListViewType) {
	UserListViewTypeFans = 0,
	UserListViewTypeFollowing,
	UserListViewTypeSearch,
};


@protocol UserListViewDelegate <NSObject>

- (UserListModel *)userListViewModelWithType:(UserListViewType)type;
- (void)userListViewRequesNewItemsWithType:(UserListViewType)type;
- (void)userListViewRequestMoreItemsWithType:(UserListViewType)type;

- (void)userListViewDidSelectedItem:(UserItem *)item;
- (void)userListViewFollowUID:(NSString *)uID
							   isFollow:(BOOL)isFollow
						 completedBlock:(UserCollectionViewCellCompletedBlock)completedBlock;



@end

@interface UserListView : UIView

@property (weak, nonatomic)id<UserListViewDelegate> customDelegate;
@property (strong, nonatomic) UICollectionView *collectionView;

- (id)initWithType:(UserListViewType)type;

- (void)setNoDataTipsHidden:(BOOL)hidden;
- (void)checkNoDataTipsStatus;

// 用于出发下拉重新刷新
- (void)beginHeaderRefreshing;

// 停止上拉和下拉刷新的动画
- (void)endAllRefreshing;

@end
