//
//  HXLoginViewController.h
//  mia
//
//  Created by miaios on 15/11/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "UIViewController+HXClass.h"

@protocol HXLoginViewControllerDelegate;

@interface HXLoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet       id  <HXLoginViewControllerDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)registerButtonPressed;
- (IBAction)loginButtonPressed;
- (IBAction)weixinButtonPressed;
- (IBAction)weiboButtonPressed;

@end

@protocol HXLoginViewControllerDelegate <NSObject>

@required
- (void)loginViewControllerLoginSuccess:(HXLoginViewController *)loginViewController;

@end