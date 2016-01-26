//
//  FriendSearchResultView.h
//  mia
//
//  Created by linyehui on 2015/09/29.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FriendModel;
@class FriendItem;

@protocol FriendSearchResultViewDelegate

- (FriendModel *)friendSearchResultViewModel;
- (void)friendSearchResultViewDidSelectedItem:(FriendItem *)item;
- (void)friendSearchResultViewRequestMoreItems;
- (void)friendSearchResultViewDidClickFollow:(FriendItem *)item;

@end

@interface FriendSearchResultView : UIView

@property (weak, nonatomic)id<FriendSearchResultViewDelegate> customDelegate;
@property (strong, nonatomic) UICollectionView *collectionView;

- (void)setNoDataTipsHidden:(BOOL)hidden;
- (void)endRefreshing;

@end
