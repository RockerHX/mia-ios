//
//  LoginViewController.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginViewControllerDelegate

- (void)loginViewControllerDidSuccess;

@end

@interface LoginViewController : UIViewController

@property (weak, nonatomic)id<LoginViewControllerDelegate> loginViewControllerDelegate;

@end

