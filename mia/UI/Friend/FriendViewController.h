//
//  SearchViewController.h
//  mia
//
//  Created by linyehui on 2016/01/26.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FriendItem;

@protocol FriendSearchViewControllerDelegate <NSObject>

@required
//- (void)friendSearchViewControllerDidSelectedItem:(FriendItem *)item;
//- (void)friendSearchViewControllerClickedFollowButtonAtItem:(FriendItem *)item;
//- (void)friendSearchViewControllerWillDismiss;
//
//@optional
//- (void)friendSearchViewControllerDismissFinished;

@end


@interface FriendViewController : UIViewController

@property (weak, nonatomic) id  <FriendSearchViewControllerDelegate>delegate;

@end

