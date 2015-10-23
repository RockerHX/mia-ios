//
//  AppDelegate.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "SingleSongPlayer.h"
#import "HXHomePageViewController.h"
#import "UserSetting.h"
#import "HXAppConstants.h"
#import "MobClick.h"
#import "HXVersion.h"

@interface AppDelegate () {
    BOOL _backBecomeActive;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 设置导航条字体颜色
    [[UINavigationBar appearance] setTintColor:UIColorFromRGB(128.0f, 128.0f, 128.0f)];
    
    // 设置后台播放模式
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    
    //启用远程控制事件接收
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

	[self registerUserDefaults];
    
#pragma mark - UMeng Analytics SDK
    // 设置版本号
    [MobClick setAppVersion:[[HXVersion appVersion] stringByAppendingFormat:@"(%@)", [HXVersion appBuildVersion]]];
    [MobClick setEncryptEnabled:YES];       // 日志加密
    // 启动[友盟统计]
//    [MobClick startWithAppkey:UMengAPPKEY reportPolicy:BATCH channelId:@"App Store"];
    [MobClick startWithAppkey:UMengAPPKEY reportPolicy:BATCH channelId:@"Fir.im"];

	return YES;
}

#pragma mark - App Delegate Methods
- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (_backBecomeActive) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HXApplicationDidBecomeActiveNotification object:nil];
    }
    _backBecomeActive = YES;
}

#pragma mark - 远程控制事件
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:event forKey:MusicPlayerMgrNotificationKey_Msg];
	[[NSNotificationCenter defaultCenter] postNotificationName:MusicPlayerMgrNotificationRemoteControlEvent object:self userInfo:userInfo];
}

- (void)registerUserDefaults {
	NSDictionary *defaultValues = [NSDictionary dictionaryWithObjectsAndKeys:
								   [NSNumber numberWithBool:NO], UserDefaultsKey_PlayWith3G,
								   [NSNumber numberWithBool:YES], UserDefaultsKey_AutoPlay,
								   nil];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

@end
