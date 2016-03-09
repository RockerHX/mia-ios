//
//  SearchViewController.h
//  mia
//
//  Created by linyehui on 2016/01/26.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserListView.h"

@class FriendItem;

@protocol FriendViewControllerDelegate <NSObject>

@optional
- (void)friendViewControllerActionDismiss;

@end


@interface FriendViewController : UIViewController

- (instancetype)initWithType:(UserListViewType)type
                      isHost:(BOOL)isHost
                         uID:(NSString *)uID
                   fansCount:(NSUInteger)fansCount
              followingCount:(NSUInteger)followingCount;

@property (weak, nonatomic)id<FriendViewControllerDelegate> delegate;

@end

