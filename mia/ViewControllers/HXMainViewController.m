//
//  HXMainViewController.m
//  mia
//
//  Created by miaios on 15/11/27.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXMainViewController.h"
#import "UserSession.h"
#import "HXLoginViewController.h"

@interface HXMainViewController () <HXLoginViewControllerDelegate>
@end

@implementation HXMainViewController {
    BOOL _firstLoad;
}

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initConfig];
    [self viewConfig];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_firstLoad) {
        [self hanleLoginState];
    }
}

#pragma mark - Config Methods
- (void)initConfig {
    _firstLoad = YES;
}

- (void)viewConfig {
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Pravite Methods
- (void)hanleLoginState {
    UserSessionLoginState loginState = [UserSession standard].state;
    if (!loginState) {
        __weak __typeof__(self)weakSelf = self;
        HXLoginViewController *loginViewController = [HXLoginViewController instance];
        loginViewController.delegate = self;
        [self presentViewController:loginViewController animated:NO completion:^{
            __strong __typeof__(self)strongSelf = weakSelf;
            strongSelf->_firstLoad = NO;
        }];
    }
}

#pragma mark - HXLoginViewControllerDelegate Methods
- (void)loginViewControllerLoginSuccess:(HXLoginViewController *)loginViewController {
}

@end
