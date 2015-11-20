//
//  HXSettingViewController.m
//  mia
//
//  Created by miaios on 15/11/20.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXSettingViewController.h"

@interface HXSettingViewController ()
@end

@implementation HXSettingViewController

#pragma mark - Class Methods
+ (instancetype)instance {
    return [[UIStoryboard storyboardWithName:@"Setting" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([HXSettingViewController class])];
}

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
}

@end
