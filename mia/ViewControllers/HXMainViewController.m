//
//  HXMainViewController.m
//  Mia
//
//  Created by miaios on 15/12/4.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXMainViewController.h"
#import "HXHomePageViewController.h"
#import "HXFavoriteViewController.h"
#import "HXMeViewController.h"

@interface HXMainViewController ()
@end

@implementation HXMainViewController

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self tabBarItemConfigure];
}

#pragma mark - Config Methods
- (void)loadConfigure {
    ;
}

- (void)viewConfigure {
    [self subControllersConfigure];
}

- (void)tabBarItemConfigure {
//    for (UIView *view in self.tabBar.subviews) {
//        if ([NSStringFromClass([view class]) isEqualToString:@"UITabBarButton"]) {
//            UILabel *label = [view.subviews firstObject];
//            label.frame = (CGRect){label.frame.origin, view.frame.size};
//            label.font = [UIFont systemFontOfSize:15.0f];
//            label.textAlignment = NSTextAlignmentCenter;
//        }
//    }
}

- (void)subControllersConfigure {
    for (UINavigationController *navigationController in self.viewControllers) {
        if ([navigationController.restorationIdentifier isEqualToString:[HXHomePageViewController navigationControllerIdentifier]]) {
            [navigationController setViewControllers:@[[HXHomePageViewController instance]]];
        } else if ([navigationController.restorationIdentifier isEqualToString:[HXFavoriteViewController navigationControllerIdentifier]]) {
            [navigationController setViewControllers:@[[HXFavoriteViewController instance]]];
        } else if ([navigationController.restorationIdentifier isEqualToString:[HXMeViewController navigationControllerIdentifier]]) {
            [navigationController setViewControllers:@[[HXMeViewController instance]]];
        }
    }
}

@end
