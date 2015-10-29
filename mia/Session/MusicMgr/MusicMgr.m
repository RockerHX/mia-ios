//
//  MusicMgr.m
//  mia
//
//  Created by linyehui on 2015/10/23.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//
//

#import "MusicMgr.h"
#import <AVFoundation/AVFoundation.h>
#import "SingleSongPlayer.h"
#import "SongListPlayer.h"
#import "WebSocketMgr.h"
#import "UIAlertView+Blocks.h"
#import "UserSetting.h"

NSString * const MusicMgrNotificationKey_Msg 			= @"msg";
NSString * const MusicMgrNotificationRemoteControlEvent	= @"MusicMgrNotificationRemoteControlEvent";

@interface MusicMgr()

@end

@implementation MusicMgr {
	UIAlertView 	*_playWith3GAlertView;	
	BOOL			_playWith3GOnceTime;		// 本次网络切换期间允许用户使用3G网络播放，网络切换后，自动重置这个开关
}

/**
 *  使用单例初始化
 *
 */
+ (id)standard{
    static MusicMgr *aMusicMgr = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        aMusicMgr = [[self alloc] init];
    });
    return aMusicMgr;
}

- (id)init {
	self = [super init];
	if (self) {
		// 设置后台播放模式
		AVAudioSession *audioSession=[AVAudioSession sharedInstance];
		[audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
		[audioSession setActive:YES error:nil];

		// 添加通知，拔出耳机后暂停播放
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remountControlEvent:) name:MusicMgrNotificationRemoteControlEvent object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReachabilityStatusChange:) name:NetworkNotificationReachabilityStatusChange object:nil];
	}

	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MusicMgrNotificationRemoteControlEvent object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NetworkNotificationReachabilityStatusChange object:nil];
}

#pragma mark - Public Methods

- (void)setCurrentPlayer:(SongListPlayer *)player {
	if ([player isEqual:_currentPlayer]) {
		NSLog(@"Same Model, do not need to reset ListPlayer.");
		return;
	}

	[_currentPlayer tearDown];
	_currentPlayer = player;
	[player setUp];
}

- (void)checkIsAllowToPlayWith3GOnceTimeWithBlock:(PlayWith3GOnceTimeBlock)playWith3GOnceTimeBlock {
	[_currentPlayer pause];

	if (![[WebSocketMgr standard] isNetworkEnable]) {
		return;
	}

	if (_playWith3GOnceTime && playWith3GOnceTimeBlock) {
		playWith3GOnceTimeBlock(YES);
		return;
	}

	if (_playWith3GAlertView) {
		NSLog(@"Last play with 3G alert view is still showing");
		if (playWith3GOnceTimeBlock) {
			playWith3GOnceTimeBlock(NO);
		}
		return;
	}

	static NSString *kAlertTitleError = @"网络连接提醒";
	static NSString *kAlertMsgNotAllowToPlayWith3G = @"您现在使用的是运营商网络，继续播放会产生流量费用。是否允许在2G/3G/4G网络下播放？";


	RIButtonItem *allowItem = [RIButtonItem itemWithLabel:@"允许播放" action:^{
		// this is the code that will be executed when the user taps "No"
		// this is optional... if you leave the action as nil, it won't do anything
		// but here, I'm showing a block just to show that you can use one if you want to.
		NSLog(@"allow to play");
		_playWith3GAlertView = nil;
		_playWith3GOnceTime = YES;
		if (playWith3GOnceTimeBlock) {
			playWith3GOnceTimeBlock(YES);
		}
	}];

	RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"取消" action:^{
		// this is the code that will be executed when the user taps "Yes"
		// delete the object in question...
		NSLog(@"cancel");
		_playWith3GAlertView = nil;
		if (playWith3GOnceTimeBlock) {
			playWith3GOnceTimeBlock(NO);
		}
	}];

	_playWith3GAlertView = [[UIAlertView alloc] initWithTitle:kAlertTitleError
													  message:kAlertMsgNotAllowToPlayWith3G
											 cancelButtonItem:cancelItem
											 otherButtonItems:allowItem, nil];
	[_playWith3GAlertView show];
}

#pragma mark - Private Methods

#pragma mark - Player Methods

- (BOOL)isPlayWith3GOnceTime {
	return _playWith3GOnceTime;
}

- (BOOL)isPlayingWithUrl:(NSString *)url {
	return [_currentPlayer isPlayingWithUrl:url];
}

- (void)pause {
	[_currentPlayer pause];
}

#pragma mark - Notification

/**
 *  一旦输出改变则执行此方法
 *
 *  @param notification 输出改变通知对象
 */
- (void)routeChange:(NSNotification *)notification {
	NSDictionary *dic=notification.userInfo;
	int changeReason= [dic[AVAudioSessionRouteChangeReasonKey] intValue];
	//等于AVAudioSessionRouteChangeReasonOldDeviceUnavailable表示旧输出不可用
	if (changeReason==AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
		AVAudioSessionRouteDescription *routeDescription=dic[AVAudioSessionRouteChangePreviousRouteKey];
		AVAudioSessionPortDescription *portDescription= [routeDescription.outputs firstObject];
		//原设备为耳机则暂停
		if ([portDescription.portType isEqualToString:@"Headphones"]) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[_currentPlayer pause];
			});
		}
	}
}

- (void)remountControlEvent:(NSNotification *)notification {
	UIEvent* event = [[notification userInfo] valueForKey:MusicMgrNotificationKey_Msg];
	NSLog(@"%li,%li",(long)event.type,(long)event.subtype);
	if(event.type==UIEventTypeRemoteControl){
		switch (event.subtype) {
			case UIEventSubtypeRemoteControlPlay:
				[_currentPlayer playCurrentItem];
				break;
			case UIEventSubtypeRemoteControlPause:
				[_currentPlayer pause];
				break;
			case UIEventSubtypeRemoteControlTogglePlayPause:
				[_currentPlayer pause];
				break;
			case UIEventSubtypeRemoteControlNextTrack:
				[_currentPlayer playNext];
				break;
			case UIEventSubtypeRemoteControlPreviousTrack:
				[_currentPlayer playPrevios];
				break;
			case UIEventSubtypeRemoteControlBeginSeekingForward:
				NSLog(@"Begin seek forward...");
				break;
			case UIEventSubtypeRemoteControlEndSeekingForward:
				NSLog(@"End seek forward...");
				break;
			case UIEventSubtypeRemoteControlBeginSeekingBackward:
				NSLog(@"Begin seek backward...");
				break;
			case UIEventSubtypeRemoteControlEndSeekingBackward:
				NSLog(@"End seek backward...");
				break;
			default:
				break;
		}
	}
}

- (void)notificationReachabilityStatusChange:(NSNotification *)notification {
	_playWith3GOnceTime = NO;

	if ([UserSetting isAllowedToPlayNowWithURL:_currentPlayer.currentItem.murl]) {
		return;
	}

	[_currentPlayer stop];
	[self checkIsAllowToPlayWith3GOnceTimeWithBlock:^(BOOL isAllowed) {
		if (isAllowed) {
			[_currentPlayer playCurrentItem];
		}
	}];
}

@end






