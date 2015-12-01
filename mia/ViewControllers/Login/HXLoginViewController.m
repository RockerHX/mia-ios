//
//  HXLoginViewController.m
//  mia
//
//  Created by miaios on 15/11/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXLoginViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "MiaAPIHelper.h"
#import "UserDefaultsUtils.h"
#import "UserSession.h"

@interface HXLoginViewController ()
@end

@implementation HXLoginViewController

#pragma mark - View Controller Life Cycle
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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
    _registerButton.layer.cornerRadius = 20.0f;
    _loginButton.layer.cornerRadius = 20.0f;
}

#pragma mark - Setter And Getter Methods
- (HXStoryBoardName)storyBoardName {
    return HXStoryBoardNameLogin;
}

#pragma mark - Event Response
- (IBAction)registerButtonPressed {
    
}

- (IBAction)loginButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(loginViewControllerLoginSuccess:)]) {
        [_delegate loginViewControllerLoginSuccess:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)weixinButtonPressed {
    [ShareSDK getUserInfo:SSDKPlatformTypeWechat onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
         if (state == SSDKResponseStateSuccess) {
             NSLog(@"uid=%@",user.uid);
             NSLog(@"%@",user.credential);
             NSLog(@"token=%@",user.credential.token);
			 NSLog(@"nickname=%@",user.nickname);

			 [MiaAPIHelper postPassportWithOpenID:user.uid
											token:user.credential.token
										 nickname:user.nickname
											  sex:(user.gender + 1)	// 微信的男女是0和1，我们的是1和2
									   headimgurl:user.icon
									completeBlock:
			  ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
				  [UserDefaultsUtils saveValue:userInfo[MiaAPIKey_Values][@"uid"] forKey:UserDefaultsKey_UID];
				  [UserDefaultsUtils saveValue:userInfo[MiaAPIKey_Values][@"token"] forKey:UserDefaultsKey_Token];

			  } timeoutBlock:^(MiaRequestItem *requestItem) {
				  NSLog(@"time out");
			  }];
         } else {
             NSLog(@"%@",error);
         }
    }];
}

- (IBAction)weiboButtonPressed {
    
}

@end
