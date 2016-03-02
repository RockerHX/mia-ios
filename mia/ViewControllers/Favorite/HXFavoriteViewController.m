//
//  HXFavoriteViewController.m
//  mia
//
//  Created by miaios on 16/2/16.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXFavoriteViewController.h"

@interface HXFavoriteViewController ()

@end

@implementation HXFavoriteViewController

#pragma mark - Class Methods
+ (NSString *)navigationControllerIdentifier {
    return @"HXFavoriteNavgationController";
}

+ (HXStoryBoardName)storyBoardName {
    return HXStoryBoardNameFavorite;
}

#pragma mark - View Controller Lift Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    ;
}

- (void)viewConfigure {
    ;
}

@end
