//
//  HXNavigationBar.m
//  mia
//
//  Created by miaios on 16/1/27.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXNavigationBar.h"
#import "HXXib.h"
#import "UIView+FindUIViewController.h"

@implementation HXNavigationBar

HXXibImplementation

#pragma mark - Event Response
- (IBAction)backButtonPressed {
    UIViewController *firstAvailableViewController = [self firstAvailableViewController];
    [firstAvailableViewController.navigationController popViewControllerAnimated:YES];
}

@end
