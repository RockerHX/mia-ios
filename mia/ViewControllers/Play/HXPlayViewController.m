//
//  HXPlayViewController.m
//  mia
//
//  Created by miaios on 16/2/25.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXPlayViewController.h"
#import "HXPlayTopBar.h"
#import "HXPlayMusicSummaryView.h"
#import "HXPlayBottomBar.h"

@interface HXPlayViewController () <
HXPlayTopBarDelegate,
HXPlayMusicSummaryViewDelegate
>
@end

@implementation HXPlayViewController

#pragma mark - Class Methods
+ (NSString *)navigationControllerIdentifier {
    return @"HXPlayNavigationController";
}

+ (HXStoryBoardName)storyBoardName {
    return HXStoryBoardNamePlay;
}

#pragma mark - View Controller Lift Cycle
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    ;
}

#pragma mark - HXPlayTopBarDelegate Methods
- (void)topBar:(HXPlayTopBar *)bar takeAction:(HXPlayTopBarAction)action {
    switch (action) {
        case HXPlayTopBarActionBack: {
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case HXPlayTopBarActionShowList: {
            ;
            break;
        }
    }
}

#pragma mark - HXPlayMusicSummaryViewDelegate Methods
- (void)summaryViewTaped:(HXPlayMusicSummaryView *)summaryView {
    ;
}

@end
