//
//  UserListView.h
//  mia
//
//  Created by linyehui on 2015/09/29.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserListModel;
@class UserItem;

typedef NS_ENUM(NSUInteger, UserListViewType) {
	UserListViewTypeFans = 0,
	UserListViewTypeFollowing,
	UserListViewTypeSearch,
};


@protocol UserListViewDelegate

- (UserListModel *)userListViewModelWithType:(UserListViewType)type;
- (void)userListViewRequestMoreItemsWithType:(UserListViewType)type;

- (void)userListViewDidSelectedItem:(UserItem *)item;

@end

@interface UserListView : UIView

@property (weak, nonatomic)id<UserListViewDelegate> customDelegate;
@property (strong, nonatomic) UICollectionView *collectionView;

- (id)initWithType:(UserListViewType)type;
- (void)setNoDataTipsHidden:(BOOL)hidden;
- (void)endRefreshing;

@end
