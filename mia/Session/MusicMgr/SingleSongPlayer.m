//
//  SingleSongPlayer.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//
//

#import "SingleSongPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "FSAudioStream.h"
#import "PathHelper.h"
#import "UserSetting.h"
#import "WebSocketMgr.h"
#import "NSObject+BlockSupport.h"
#import "NSString+IsNull.h"
#import "UIAlertView+Blocks.h"
#import "MusicItem.h"

static NSString * const SingleSongPlayerNotificationKey_Msg				= @"msg";

static NSString * const SingleSongPlayerNotificationRemoteControlEvent	= @"SingleSongPlayerNotificationRemoteControlEvent";

typedef void(^PlayWith3GOnceTimeBlock)(BOOL isAllowed);

@interface SingleSongPlayer()

@end

@implementation SingleSongPlayer {
	FSAudioStream 	*_audioStream;
	UIAlertView 	*_playWith3GAlertView;
	BOOL			_playWith3GOnceTime;		// 本次网络切换期间允许用户使用3G网络播放，网络切换后，自动重置这个开关
}

- (id)init {
	self = [super init];
	if (self) {
		// init audioStream
		FSStreamConfiguration *defaultConfiguration = [[FSStreamConfiguration alloc] init];
		defaultConfiguration.cacheDirectory = [PathHelper playCacheDir];
		_audioStream = [[FSAudioStream alloc] initWithConfiguration:defaultConfiguration];
		_audioStream.strictContentTypeChecking = NO;
		_audioStream.defaultContentType = @"audio/mpeg";

		__weak SingleSongPlayer *weakPlayer = self;
		_audioStream.onCompletion = ^() {
			SingleSongPlayer *strongPlayer = weakPlayer;
			[strongPlayer stop];
			if ([strongPlayer delegate]) {
				[[strongPlayer delegate] singleSongPlayerDidCompletion];
			}
		};

		/*
		__weak FSAudioStream *weakStream = audioStream;
		audioStream.onStateChange = ^(FSAudioStreamState state) {
			NSString *stateName = @"";
			switch (state) {
				case kFsAudioStreamRetrievingURL:
					stateName = @"kFsAudioStreamRetrievingURL";
					break;
				case kFsAudioStreamStopped:
					stateName = @"kFsAudioStreamStopped";
					break;
				case kFsAudioStreamBuffering:
					stateName = @"kFsAudioStreamBuffering";
					break;
				case kFsAudioStreamPlaying:
					stateName = @"kFsAudioStreamPlaying";
					break;
				case kFsAudioStreamPaused:
					stateName = @"kFsAudioStreamPaused";
					break;
				case kFsAudioStreamSeeking:
					stateName = @"kFsAudioStreamSeeking";
					break;
				case kFSAudioStreamEndOfFile:
					stateName = @"kFSAudioStreamEndOfFile";
					break;
				case kFsAudioStreamFailed:
					stateName = @"kFsAudioStreamFailed";
					break;
				case kFsAudioStreamRetryingStarted:
					stateName = @"kFsAudioStreamRetryingStarted";
					break;
				case kFsAudioStreamRetryingSucceeded:
					stateName = @"kFsAudioStreamRetryingSucceeded";
					break;
				case kFsAudioStreamRetryingFailed:
					stateName = @"kFsAudioStreamRetryingFailed";
					break;
				case kFsAudioStreamPlaybackCompleted:
					stateName = @"kFsAudioStreamPlaybackCompleted";
					break;
				case kFsAudioStreamUnknownState:
					stateName = @"kFsAudioStreamUnknownState";
					break;
				default:
					break;
			}
			NSLog(@"onStateChange:%@, %@", stateName, weakStream.url);
		};
		*/
		_audioStream.onFailure = ^(FSAudioStreamError error, NSString *errorDescription) {
			NSLog(@"onFailure:%d, %@", error, errorDescription);
		};

		// 设置后台播放模式
		AVAudioSession *audioSession=[AVAudioSession sharedInstance];
		[audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
		[audioSession setActive:YES error:nil];

		// 添加通知，拔出耳机后暂停播放
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remountControlEvent:) name:SingleSongPlayerNotificationRemoteControlEvent object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReachabilityStatusChange:) name:NetworkNotificationReachabilityStatusChange object:nil];

	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:SingleSongPlayerNotificationRemoteControlEvent object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NetworkNotificationReachabilityStatusChange object:nil];
}

- (void)playWithMusicItem:(MusicItem *)item {
	NSLog(@"playWithUrl %@", item.murl);
	if ([self isPlayingWithUrl:item.murl]) {
		// 同一个模块再次播放同一首歌，什么都不做
		NSLog(@"play the same song in the same model, play will be ignored.");
		return;
	}

	if (![UserSetting isAllowedToPlayNowWithURL:item.murl]) {
		[self checkBeforePlayWithUrl:item.murl title:item.name artist:item.singerName];
		return;
	}

	[self playWithoutCheckWithUrl:item.murl title:item.name artist:item.singerName];
}

- (BOOL)isPlayWith3GOnceTime {
	return _playWith3GOnceTime;
}

- (BOOL)isPlaying {
	if (_audioStream) {
		return [_audioStream isPlaying];
	} else {
		return NO;
	}
}

- (BOOL)isPlayingWithUrl:(NSString *)url {
	if (!_audioStream) {
		return NO;
	}
	if (![_audioStream isPlaying]) {
		return NO;
	}

	return [_audioStream.url.absoluteString isEqualToString:url];
}

- (void)play {
	if (![_audioStream url])
		return;

	if (![UserSetting isAllowedToPlayNowWithURL:[[_audioStream url] absoluteString]]) {
		[self checkIsAllowToPlayWith3GOnceTimeWithBlock:^(BOOL isAllowed) {
			if (isAllowed) {
				[self play];
			}
		}];

		return;
	}

	NSLog(@"play:%@", [_audioStream url]);
	NSLog(@"#SingleSongPlayer# play - resume play from pause");
	[_audioStream pause];

	if (_delegate) {
		[_delegate singleSongPlayerDidPlay];
	}
}

- (void)pause {
	NSLog(@"#SingleSongPlayer# pause");
	[_audioStream pause];

	if ([_audioStream isPlaying]) {
		if (_delegate) {
			[_delegate singleSongPlayerDidPlay];
		}
	} else {
		if (_delegate) {
			[_delegate singleSongPlayerDidPause];
		}
	}

}

- (void)stop {
	[_audioStream stop];
	_audioStream.url = nil;

	if (_delegate) {
		[_delegate singleSongPlayerDidPause];
	}
}

- (float)playPosition {
	if (!_audioStream) {
		return 0.0;
	} else {
		return [_audioStream currentTimePlayed].position;
	}
}

#pragma mark -private method

- (void)playWithoutCheckWithUrl:(NSString*)url title:(NSString *)title artist:(NSString *)artist {
	if (![_audioStream url]) {
		// 没有设置过歌曲url，直接播放
		NSLog(@"#SingleSongPlayer# playFromURL - first or last is completion.");
		[_audioStream playFromURL:[NSURL URLWithString:url]];
	} else if ([[[_audioStream url] absoluteString] isEqualToString:url]) {
		// 同一首歌，暂停状态，直接调用pause恢复播放就可以了
		if ([_audioStream isPlaying]) {
			NSLog(@"resume music from pause error, stop and play again.");
			[self playAnotherWirUrl:url];
		} else {
			NSLog(@"#SingleSongPlayer# playWithUrl - resume play from pause");
			[_audioStream pause];
		}
	} else {
		// 切换歌曲
		[self playAnotherWirUrl:url];
	}

	[self setMediaInfo:nil andTitle:title andArtist:artist];

	if (_delegate) {
		[_delegate singleSongPlayerDidPlay];
	}
}

- (void)playAnotherWirUrl:(NSString *)url{
	NSLog(@"#SingleSongPlayer# stop - stop before playAnotherWirUrl");
	[_audioStream stop];
	NSLog(@"#SingleSongPlayer# performBlock");
	[self bs_performBlock:^{
		NSLog(@"#SingleSongPlayer# delayPlayHandlerWithUrl");
		[_audioStream playFromURL:[NSURL URLWithString:url]];
	} afterDelay:0.5f];
}

- (void)checkBeforePlayWithUrl:(NSString*)url title:(NSString *)title artist:(NSString *)artist {
	[self checkIsAllowToPlayWith3GOnceTimeWithBlock:^(BOOL isAllowed) {
		if (isAllowed) {
			[self playWithoutCheckWithUrl:url title:title artist:artist];
		}
	}];
}

- (void)checkIsAllowToPlayWith3GOnceTimeWithBlock:(PlayWith3GOnceTimeBlock)playWith3GOnceTimeBlock {
	if (_delegate) {
		[_delegate singleSongPlayerDidPause];
	}

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
				[self pause];
			});
		}
	}
}

- (void)remountControlEvent:(NSNotification *)notification {
	UIEvent* event = [[notification userInfo] valueForKey:SingleSongPlayerNotificationKey_Msg];
	NSLog(@"%li,%li",(long)event.type,(long)event.subtype);
	if(event.type==UIEventTypeRemoteControl){
		switch (event.subtype) {
			case UIEventSubtypeRemoteControlPlay:
				[self play];
				break;
			case UIEventSubtypeRemoteControlPause:
				[self pause];
				break;
			case UIEventSubtypeRemoteControlTogglePlayPause:
				[self pause];
				break;
			case UIEventSubtypeRemoteControlNextTrack:
				NSLog(@"Next...");
				break;
			case UIEventSubtypeRemoteControlPreviousTrack:
				NSLog(@"Previous...");
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

	if (![_audioStream isPlaying]) {
		return;
	}
	if ([UserSetting isAllowedToPlayNowWithURL:[[_audioStream url] absoluteString]]) {
		return;
	}

	[self stop];
	[self checkIsAllowToPlayWith3GOnceTimeWithBlock:^(BOOL isAllowed) {
		if (isAllowed) {
			[self play];
		}
	}];
}

#pragma mark - audio operations

- (void) setMediaInfo : (UIImage *) img andTitle : (NSString *) title andArtist : (NSString *) artist
{
	if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
		NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];


		[dict setObject:title forKey:MPMediaItemPropertyAlbumTitle];
		[dict setObject:artist forKey:MPMediaItemPropertyArtist];

		float totalSeconds = [_audioStream duration].minute * 60.0 + [_audioStream duration].second;
		[dict setObject:[NSNumber numberWithFloat:totalSeconds] forKey:MPMediaItemPropertyPlaybackDuration];
		[dict setObject:[NSNumber numberWithFloat:[_audioStream currentTimePlayed].playbackTimeInSeconds] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];

		//		MPMediaItemArtwork * mArt = [[MPMediaItemArtwork alloc] initWithImage:img];
		//		[dict setObject:mArt forKey:MPMediaItemPropertyArtwork];
		[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nil;
		[[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
	}
}


@end
















