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

@required
//@optional
//- (void)friendSearchViewControllerDismissFinished;

@end


@interface FriendViewController : UIViewController

@property (weak, nonatomic) id<FriendViewControllerDelegate> delegate;

- (id)initWithType:(UserListViewType)type;

@end

