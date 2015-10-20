//
//  AppDelegate.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "MusicPlayerMgr.h"
#import "RadioViewController.h"
#import "HXHomePageViewController.h"
#import "UserSetting.h"
#import "HXAppConstants.h"

@interface AppDelegate () {
    BOOL _backBecomeActive;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 设置后台播放模式
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    
    //启用远程控制事件接收
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

	[self registerUserDefaults];

	return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (_backBecomeActive) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HXApplicationDidBecomeActiveNotification object:nil];
    }
    _backBecomeActive = YES;
}

#pragma mark 远程控制事件
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
