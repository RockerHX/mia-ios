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
#import "HXRadioViewController.h"
#import "UserSetting.h"

@interface AppDelegate ()

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
    
    
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
	RadioViewController *radioViewController = [[RadioViewController alloc] init];
//    HXRadioViewController *radioViewController = [[UIStoryboard storyboardWithName:@"Radio" bundle:nil] instantiateViewControllerWithIdentifier:@"HXRadioViewController"];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:radioViewController];
	[navigationController setNavigationBarHidden:YES animated:NO];
	[self.window setRootViewController:navigationController];
    
    
	[self.window makeKeyAndVisible];

	[self registerUserDefaults];

	return YES;
}

#pragma mark 远程控制事件
-(void)remoteControlReceivedWithEvent:(UIEvent *)event {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:event forKey:MusicPlayerMgrNotificationUserInfoKey];
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
