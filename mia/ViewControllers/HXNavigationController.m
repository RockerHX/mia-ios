//
//  HXNavigationController.m
//  mia
//
//  Created by miaios on 15/11/2.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXNavigationController.h"

@interface HXNavigationController () <UIGestureRecognizerDelegate>
@end

@implementation HXNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.interactivePopGestureRecognizer.delegate = self;
}

#pragma mark - UIGestureRecognizerDelegate Methods
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.viewControllers.count <= 1) {
        return NO;
    }
    return YES;
}

@end
