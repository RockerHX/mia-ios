//
//  AppDelegate.m
//  mia
//
//  Created by miaios on 16/2/16.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import "UserSetting.h"
#import "MusicMgr.h"
#import "HXAppConstants.h"

// Share SDK
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import "WXApi.h"
//#import "WeiboSDK.h"
#import "HXVersion.h"

@interface AppDelegate () {
    BOOL _backBecomeActive;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15.0f]}];
    
	//启用远程控制事件接收
	[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	// 默认用户配置
    [UserSetting registerUserDefaults];
    
#pragma mark - Share SDK
    NSArray *activePlatforms = @[@(SSDKPlatformTypeWechat),
                                 @(SSDKPlatformTypeSMS)/*,
                                                        @(SSDKPlatformTypeMail),
                                                        @(SSDKPlatformTypeSinaWeibo)*/];
    [ShareSDK registerApp:ShareSDKKEY activePlatforms:activePlatforms onImport:^(SSDKPlatformType platformType) {
        switch (platformType) {
            case SSDKPlatformTypeWechat: {
                [ShareSDKConnector connectWeChat:[WXApi class]];
                break;
            }
//            case SSDKPlatformTypeSinaWeibo: {
//                [ShareSDKConnector connectWeibo:[WeiboSDK class]];
//                break;
//            }
            default:
                break;
        }
    } onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
        switch (platformType) {
            case SSDKPlatformTypeWechat: {
                [appInfo SSDKSetupWeChatByAppId:WeiXinKEY
                                      appSecret:WeiXinSecret];
                break;
            }
//            case SSDKPlatformTypeSinaWeibo: {
//                //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
//                [appInfo SSDKSetupSinaWeiboByAppKey:@"568898243"
//                appSecret:@"38a4f8204cc784f81f9f0daaf31e02e3"
//                redirectUri:@"http://www.sharesdk.cn"
//                authType:SSDKAuthTypeBoth];
//                break;
//            }
            default:
                break;
        }
    }];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

	// 切换回前台主动取消被打断状态
	[MusicMgr standard].isInterruption = NO;

	// 设置后台播放模式
	AVAudioSession *audioSession=[AVAudioSession sharedInstance];
	[audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
	[audioSession setActive:YES error:nil];

	if (_backBecomeActive) {
		[[NSNotificationCenter defaultCenter] postNotificationName:HXApplicationDidBecomeActiveNotification object:nil];
	}
	_backBecomeActive = YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - 远程控制事件
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:event forKey:MusicMgrNotificationKey_RemoteControlEvent];
	[[NSNotificationCenter defaultCenter] postNotificationName:MusicMgrNotificationRemoteControlEvent object:self userInfo:userInfo];
}

@end
