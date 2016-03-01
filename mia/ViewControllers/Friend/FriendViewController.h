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

@interface FriendViewController : UIViewController

- (instancetype)initWithType:(UserListViewType)type
                      isHost:(BOOL)isHost
                         uID:(NSString *)uID
                   fansCount:(NSUInteger)fansCount
              followingCount:(NSUInteger)followingCount;

@end

