//
//  HXPlayerViewController.m
//  mia
//
//  Created by miaios on 15/12/1.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXPlayerViewController.h"

@interface HXPlayerViewController ()
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

@end
