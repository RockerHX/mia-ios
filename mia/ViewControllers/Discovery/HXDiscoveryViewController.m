//
//  HXDiscoveryViewController.m
//  mia
//
//  Created by miaios on 16/2/16.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXDiscoveryViewController.h"
#import "HXDiscoveryHeader.h"

@interface HXDiscoveryViewController () <
HXDiscoveryHeaderDelegate
>

@end

@implementation HXDiscoveryViewController

#pragma mark - Class Methods
+ (NSString *)navigationControllerIdentifier {
    return @"HXDiscoveryNavgationController";
}

+ (HXStoryBoardName)storyBoardName {
    return HXStoryBoardNameDiscovery;
}

#pragma mark - View Controller Lift Cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - HXDiscoveryHeaderDelegate Methods
- (void)discoveryActionHeader:(HXDiscoveryHeader *)header takeAction:(HXDiscoveryHeaderAction)action {
    switch (action) {
        case HXDiscoveryHeaderActionProfile: {
            ;
            break;
        }
        case HXDiscoveryHeaderActionShare: {
            ;
            break;
        }
    }
}

@end
