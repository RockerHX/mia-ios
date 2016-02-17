//
//  HXMeViewController.m
//  mia
//
//  Created by miaios on 16/2/17.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXMeViewController.h"

@interface HXMeViewController ()

@end

@implementation HXMeViewController

#pragma mark - Class Methods
+ (NSString *)navigationControllerIdentifier {
    return @"HXMeNavgationController";
}

+ (HXStoryBoardName)storyBoardName {
    return HXStoryBoardNameMe;
}

#pragma mark - View Controller Lift Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

@end
