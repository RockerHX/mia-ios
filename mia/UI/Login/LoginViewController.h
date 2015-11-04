//
//  LoginViewController.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginViewControllerDelegate <NSObject>

- (void)loginViewControllerDismissWithoutLogin;
- (void)loginViewControllerDidSuccess;

@end

@interface LoginViewController : UIViewController

@property (weak, nonatomic)id<LoginViewControllerDelegate> customDelegate;

- (void)loginSuccess:(void(^)(BOOL success))success;

@end

