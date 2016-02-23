//
//  HXMainViewController.m
//  Mia
//
//  Created by miaios on 15/12/4.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXMainViewController.h"
#import "HXDiscoveryViewController.h"
#import "HXFavoriteViewController.h"
#import "HXMeViewController.h"
#import "HXUserSession.h"
#import "HXLoginViewController.h"

@interface HXMainViewController () <
UITabBarControllerDelegate
>
@end

@implementation HXMainViewController

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Config Methods
- (void)loadConfigure {
    self.delegate = self;
}

- (void)viewConfigure {
    [self subControllersConfigure];
}

- (void)subControllersConfigure {
    for (UINavigationController *navigationController in self.viewControllers) {
        if ([navigationController.restorationIdentifier isEqualToString:[HXDiscoveryViewController navigationControllerIdentifier]]) {
            [navigationController setViewControllers:@[[HXDiscoveryViewController instance]]];
        } else if ([navigationController.restorationIdentifier isEqualToString:[HXFavoriteViewController navigationControllerIdentifier]]) {
            [navigationController setViewControllers:@[[HXFavoriteViewController instance]]];
        } else if ([navigationController.restorationIdentifier isEqualToString:[HXMeViewController navigationControllerIdentifier]]) {
            [navigationController setViewControllers:@[[HXMeViewController instance]]];
        }
    }
}

#pragma mark - Private Methods
- (void)showLoginSence {
    [self presentViewController:[HXLoginViewController navigationControllerInstance] animated:YES completion:nil];
}

#pragma mark - UITabBarControllerDelegate Methods
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (![[self.viewControllers firstObject] isEqual:viewController]) {
        switch ([HXUserSession share].state) {
            case HXUserStateLogout: {
                [self showLoginSence];
                return NO;
                break;
            }
            case HXUserStateLogin: {
                return YES;
                break;
            }
        }
    }
    return YES;
}

@end
