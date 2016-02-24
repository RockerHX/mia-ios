//
//  MusicMgr.m
//  mia
//
//  Created by linyehui on 2015/10/23.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//
//

#import "MusicMgr.h"
#import "ShareItem.h"
#import "SingleSongPlayer.h"
#import "SongPreloader.h"
#import "WebSocketMgr.h"
#import "UserSetting.h"
#import "FileLog.h"
#import "UIAlertView+BlocksKit.h"
#import "NSObject+BlockSupport.h"

NSString * const MusicMgrNotificationKey_Msg 			= @"msg";
NSString * const MusicMgrNotificationRemoteControlEvent	= @"MusicMgrNotificationRemoteControlEvent";

@interface MusicMgr() <SingleSongPlayerDelegate, SongPreloaderDelegate>

@end

@implementation MusicMgr {
	SingleSongPlayer		*_player;
	SongPreloader			*_preloader;

	UIAlertView 			*_playWith3GAlertView;
	BOOL					_playWith3GOnceTime;		// 本次网络切换期间允许用户使用3G网络播放，网络切换后，自动重置这个开关
}

/**
 *  使用单例初始化
 *
 */
+ (MusicMgr *)standard{
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
		_player = [[SingleSongPlayer alloc] init];
		_preloader = [[SongPreloader alloc] init];
		_preloader.delegate = self;

		// 添加通知，拔出耳机后暂停播放
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remountControlEvent:) name:MusicMgrNotificationRemoteControlEvent object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReachabilityStatusChange:) name:NetworkNotificationReachabilityStatusChange object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruption:) name:AVAudioSessionInterruptionNotification object:nil];
	}

	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MusicMgrNotificationRemoteControlEvent object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NetworkNotificationReachabilityStatusChange object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
}

#pragma mark - Getter and Setter
- (void)setPlayList:(NSMutableArray *)playList {
	// TODO 切换歌单的话需要先停止再开始播放
}

- (ShareItem *)getCurrentItem {
	// TODO
	return nil;
}

- (ShareItem *)getNextItem {
	// TODO
	return nil;
}

#pragma mark - Public Methods

- (void)checkIsAllowToPlayWith3GOnceTimeWithBlock:(PlayWith3GOnceTimeBlock)playWith3GOnceTimeBlock {
	[_player pause];

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
    
    _playWith3GAlertView = [UIAlertView bk_showAlertViewWithTitle:kAlertTitleError
                                                          message:kAlertMsgNotAllowToPlayWith3G
                                                cancelButtonTitle:@"取消"
                                                otherButtonTitles:@[@"允许播放"]
                                                          handler:
                            ^(UIAlertView *alertView, NSInteger buttonIndex) {
                                if (alertView.cancelButtonIndex == buttonIndex) {
                                    NSLog(@"cancel");
                                    _playWith3GAlertView = nil;
                                    if (playWith3GOnceTimeBlock) {
                                        playWith3GOnceTimeBlock(NO);
                                    }
                                } else {
                                    NSLog(@"allow to play");
                                    _playWith3GAlertView = nil;
                                    _playWith3GOnceTime = YES;
                                    if (playWith3GOnceTimeBlock) {
                                        playWith3GOnceTimeBlock(YES);
                                    }
                                }
                            }];
}

#pragma mark - Player Methods

- (BOOL)isPlayWith3GOnceTime {
	return _playWith3GOnceTime;
}

- (void)playCurrentItem {
//	[_player playWithMusicItem:[self currentItem]];
}

- (void)playWithItem:(ShareItem *)item {
	[_preloader stop];
	[_player playWithMusicItem:item.music];
}

- (void)playNext {
//	if (_delegate && [_delegate respondsToSelector:@selector(songListPlayerShouldPlayNext)]) {
//		[_delegate songListPlayerShouldPlayNext];
//	}
}

- (void)playPrevios {
//	if (_delegate && [_delegate respondsToSelector:@selector(songListPlayerShouldPlayPrevios)]) {
//		[_delegate songListPlayerShouldPlayPrevios];
//	}
}

- (BOOL)isPlaying {
	return [_player isPlaying];
}

- (BOOL)isPlayingWithUrl:(NSString *)url {
	return [_player isPlayingWithUrl:url];
}

- (void)pause {
	[_player pause];
}

- (void)stop {
	[_player stop];
	[_preloader stop];
}

- (float)playPosition {
	return [_player playPosition];
}

#pragma mark - Notification
/**
 *  一旦输出改变则执行此方法
 *
 *  @param notification 输出改变通知对象
 */
- (void)routeChange:(NSNotification *)notification {
	NSDictionary *dic = notification.userInfo;
	int changeReason = [dic[AVAudioSessionRouteChangeReasonKey] intValue];
	//等于AVAudioSessionRouteChangeReasonOldDeviceUnavailable表示旧输出不可用
	if (changeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
		AVAudioSessionRouteDescription *routeDescription = dic[AVAudioSessionRouteChangePreviousRouteKey];
		AVAudioSessionPortDescription *portDescription = [routeDescription.outputs firstObject];
		//原设备为耳机则暂停
		if ([portDescription.portType isEqualToString:@"Headphones"]) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if ([_player isPlaying]) {
					[_player pause];
					[[FileLog standard] log:@"routechange last device is headphone, pause"];
				}
			});
		}
	}
}

- (void)remountControlEvent:(NSNotification *)notification {
	UIEvent* event = [[notification userInfo] valueForKey:MusicMgrNotificationKey_Msg];
	NSLog(@"%li,%li",(long)event.type,(long)event.subtype);
	if(event.type == UIEventTypeRemoteControl){
		switch (event.subtype) {
			case UIEventSubtypeRemoteControlPlay:
				[self playCurrentItem];
				break;
			case UIEventSubtypeRemoteControlPause:
				[self pause];
				break;
			case UIEventSubtypeRemoteControlTogglePlayPause:
				[self pause];
				break;
			case UIEventSubtypeRemoteControlNextTrack:
				[self playNext];
				break;
			case UIEventSubtypeRemoteControlPreviousTrack:
				[self playPrevios];
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

	if ([UserSetting isAllowedToPlayNowWithURL:_player.currentItem.murl]) {
		return;
	}

	[_player stop];
	[self checkIsAllowToPlayWith3GOnceTimeWithBlock:^(BOOL isAllowed) {
		if (isAllowed) {
			[self playCurrentItem];
		}
	}];
}

- (void)interruption:(NSNotification*)notification {
	NSDictionary *interuptionDict = notification.userInfo;
	NSInteger interuptionType = [[interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
	switch (interuptionType) {
		case AVAudioSessionInterruptionTypeBegan:
			[[FileLog standard] log:@"Audio Session Interruption case started."];
			_isInterruption = YES;
			break;

		case AVAudioSessionInterruptionTypeEnded:
			[[FileLog standard] log:@"Audio Session Interruption case ended."];
			_isInterruption = NO;
			break;
		default:
			[[FileLog standard] log:@"Audio Session Interruption Notification case default: %d", interuptionType];
			break;
	}
}

#pragma mark - SingleSongPlayerDelegate
- (void)singleSongPlayerDidPlay {
	// TODO 改成通知
//	if (_delegate) {
//		[_delegate songListPlayerDidPlay];
//	}
}

- (void)singleSongPlayerDidPause {
	// TODO 改成通知
//	if (_delegate) {
//		[_delegate songListPlayerDidPause];
//	}
}

- (void)singleSongPlayerDidCompletion {
	// TODO 改成通知
//	if (_delegate) {
//		[_delegate songListPlayerDidCompletion];
//	}
}

- (void)singleSongPlayerDidBufferStream {
	[self bs_performBlock:^{
		NSLog(@"delayPreloader");
		if (_nextItem) {
			[_preloader preloadWithMusicItem:_nextItem.music];
		}
	} afterDelay:30.0f];
}

- (void)singleSongPlayerDidFailure {
	// TODO 改成通知
	//	if (_delegate) {
	//		[_delegate songListPlayerDidPause];
	//	}
}

#pragma mark - SongPreloaderDelegate
- (BOOL)songPreloaderIsPlayerLoadedThisUrl:(NSString *)url {
	return [_player.currentItem.murl isEqualToString:url];
}

@end






