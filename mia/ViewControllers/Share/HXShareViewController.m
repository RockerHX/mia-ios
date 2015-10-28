//
//  HXShareViewController.m
//  mia
//
//  Created by miaios on 15/10/28.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXShareViewController.h"

@interface HXShareViewController ()
@end

@implementation HXShareViewController

#pragma mark - View Controller Life Cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
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

#pragma mark - Public Methods
+ (instancetype)instance {
    return [[UIStoryboard storyboardWithName:@"Share" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([HXShareViewController class])];
}

@end
