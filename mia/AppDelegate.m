//
//  AppDelegate.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "MusicMgr.h"
#import "HXHomePageViewController.h"
#import "UserSetting.h"
#import "HXAppConstants.h"
#import "MobClick.h"
#import "HXVersion.h"
#import "UIImage+ColorToImage.h"

// Share SDK
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import "WXApi.h"
//#import "WeiboSDK.h"

@interface AppDelegate () {
    BOOL _backBecomeActive;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //启用远程控制事件接收
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

	[self registerUserDefaults];
    
#ifdef DEBUG
#else
#pragma mark - UMeng Analytics SDK
    // 设置版本号
    [MobClick setAppVersion:[[HXVersion appVersion] stringByAppendingFormat:@"(%@)", [HXVersion appBuildVersion]]];
    [MobClick setEncryptEnabled:YES];       // 日志加密
    // 启动[友盟统计]
    [MobClick setCrashReportEnabled:NO];
    [MobClick startWithAppkey:UMengAPPKEY reportPolicy:BATCH channelId:FirimChannel];
//	[MobClick startWithAppkey:UMengAPPKEY reportPolicy:BATCH channelId:AppstoreChannel];

//#pragma mark - Testin Crash SDK
//    [TestinAgent init:TestinAPPKEY channel:FirimChannel config:[TestinConfig defaultConfig]];
#endif
    
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

#pragma mark - App Delegate Methods
- (void)applicationDidBecomeActive:(UIApplication *)application {
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

#pragma mark - 远程控制事件
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:event forKey:MusicMgrNotificationKey_Msg];
	[[NSNotificationCenter defaultCenter] postNotificationName:MusicMgrNotificationRemoteControlEvent object:self userInfo:userInfo];
}

- (void)registerUserDefaults {
	NSDictionary *defaultValues = [NSDictionary dictionaryWithObjectsAndKeys:
								   [NSNumber numberWithBool:NO], UserDefaultsKey_PlayWith3G,
								   [NSNumber numberWithBool:YES], UserDefaultsKey_AutoPlay,
								   nil];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

@end
