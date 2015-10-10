//
//  HXRadioViewController.m
//  mia
//
//  Created by miaios on 15/10/9.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXRadioViewController.h"
#import "UserSession.h"
#import "LoginViewController.h"
#import "ProfileViewController.h"
#import "ShareViewController.h"

@interface HXRadioViewController () <LoginViewControllerDelegate>

@end

@implementation HXRadioViewController

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Event Response
- (IBAction)profileButtonPressed {
    if ([[UserSession standard] isLogined]) {
        ProfileViewController *vc = [[ProfileViewController alloc] initWitUID:[[UserSession standard] uid]
                                                                     nickName:[[UserSession standard] nick]
                                                                  isMyProfile:YES];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        LoginViewController *vc = [[LoginViewController alloc] init];
        vc.loginViewControllerDelegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)shareButtonPressed {
    if ([[UserSession standard] isLogined]) {
        ShareViewController *vc = [[ShareViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        LoginViewController *vc = [[LoginViewController alloc] init];
        vc.loginViewControllerDelegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Login View Controller Delegate Methods
- (void)loginViewControllerDidSuccess {
    
}

@end
