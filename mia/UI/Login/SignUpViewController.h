//
//  SignUpViewController.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SignUpViewControllerDelegate

- (void)signUpViewControllerDidPop:(BOOL)success;

@end

@interface SignUpViewController : UIViewController

@property (weak, nonatomic)id<SignUpViewControllerDelegate> signUpViewControllerDelegate;

@end

