//
//  ProfileViewController.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProfileViewControllerDelegate

- (void)profileViewControllerWillDismiss;
- (void)profileViewControllerUpdateUnreadCount:(int)count;

@end


@interface ProfileViewController : UIViewController

- (id)initWitUID:(NSString *)uid nickName:(NSString *)nickName isMyProfile:(BOOL)isMyProfile;

@property (weak, nonatomic)id<ProfileViewControllerDelegate> customDelegate;
@property (assign, nonatomic) BOOL playFavoriteOnceTime;

@end

