//
//  MyProfileViewController.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyProfileViewControllerDelegate

- (void)myProfileViewControllerWillDismiss;
- (void)myProfileViewControllerUpdateUnreadCount:(int)count;

@end


@interface MyProfileViewController : UIViewController

- (id)initWitUID:(NSString *)uid nickName:(NSString *)nickName;

@property (weak, nonatomic)id<MyProfileViewControllerDelegate> customDelegate;
@property (assign, nonatomic) BOOL playFavoriteOnceTime;

@end

