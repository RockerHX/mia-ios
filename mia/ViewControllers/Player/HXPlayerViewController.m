//
//  HXPlayerViewController.m
//  mia
//
//  Created by miaios on 15/12/1.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXPlayerViewController.h"
#import "HXPlayerInfoView.h"
#import "HXPlayerProgressView.h"
#import "HXPlayerActionBar.h"

@interface HXPlayerViewController () <HXPlayerActionBarDelegate>
@end

@implementation HXPlayerViewController

#pragma mark - View Controller Life Cycle
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
    
    [self initConfig];
    [self viewConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
}

- (void)viewConfig {
}

#pragma mark - Setter And Getter Methods
- (NSString *)navigationControllerIdentifier {
    return @"HXPlayerNavigationController";
}

- (HXStoryBoardName)storyBoardName {
    return HXStoryBoardNamePlayer;
}

#pragma mark - Event Response
- (IBAction)backButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - HXPlayerActionBarDelegate Methods
- (void)actionBar:(HXPlayerActionBar *)bar action:(HXPlayerActionBarAction)action {
    switch (action) {
        case HXPlayerActionBarActionPrevious: {
            ;
            break;
        }
        case HXPlayerActionBarActionPlay: {
            ;
            break;
        }
        case HXPlayerActionBarActionPause: {
            ;
            break;
        }
        case HXPlayerActionBarActionNext: {
            ;
            break;
        }
    }
}

@end
