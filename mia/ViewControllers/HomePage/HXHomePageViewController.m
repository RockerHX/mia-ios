//
//  HXHomePageViewController.m
//  mia
//
//  Created by miaios on 16/2/16.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXHomePageViewController.h"

@interface HXHomePageViewController ()

@end

@implementation HXHomePageViewController

#pragma mark - Class Methods
+ (NSString *)navigationControllerIdentifier {
    return @"HXHomePageNavgationController";
}

+ (HXStoryBoardName)storyBoardName {
    return HXStoryBoardNameHomePage;
}

#pragma mark - View Controller Lift Cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

@end
