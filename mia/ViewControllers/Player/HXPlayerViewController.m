//
//  HXPlayerViewController.m
//  mia
//
//  Created by miaios on 15/12/1.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXPlayerViewController.h"
#import "HXPlayerTopBar.h"
#import "HXPlayerInfoView.h"
#import "HXPlayerProgressView.h"
#import "HXPlayerActionBar.h"

@interface HXPlayerViewController () <HXPlayerTopBarDelegate, HXPlayerActionBarDelegate>
@end

@implementation HXPlayerViewController

#pragma mark - View Controller Life Cycle
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
- (HXStoryBoardName)storyBoardName {
    return HXStoryBoardNamePlayer;
}

#pragma mark - HXPlayerTopBarDelegate Methods
- (void)topBar:(HXPlayerTopBar *)bar action:(HXPlayerTopBarAction)action {
    switch (action) {
        case HXPlayerTopBarActionBack: {
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case HXPlayerTopBarActionList: {
            ;
            break;
        }
    }
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
