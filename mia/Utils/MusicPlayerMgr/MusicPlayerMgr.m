//
//  MusicPlayerMgr.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//
//

#import "MusicPlayerMgr.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "FSAudioStream.h"

NSString * const MusicPlayerMgrNotificationUserInfoKey			= @"msg";

NSString * const MusicPlayerMgrNotificationRemoteControlEvent	= @"MusicPlayerMgrNotificationRemoteControlEvent";
NSString * const MusicPlayerMgrNotificationDidPlay			 	= @"MusicPlayerMgrNotificationDidPlay";
NSString * const MusicPlayerMgrNotificationDidPause			 	= @"MusicPlayerMgrNotificationDidPause";
NSString * const MusicPlayerMgrNotificationCompletion			= @"MusicPlayerMgrNotificationCompletion";

@interface MusicPlayerMgr()

@end

@implementation MusicPlayerMgr {
	FSAudioStream *audioStream;
}

/**
 *  使用单例初始化
 *
 */
+(id)standard{
    static MusicPlayerMgr *aMusicPlayerMgr = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        aMusicPlayerMgr = [[self alloc] init];
    });
    return aMusicPlayerMgr;
}

- (id)init {
	self = [super init];
	if (self) {
		// init audioStream
		audioStream = [[FSAudioStream alloc] init];
		audioStream.strictContentTypeChecking = NO;
		audioStream.defaultContentType = @"audio/mpeg";
		audioStream.onCompletion = ^() {
			[[NSNotificationCenter defaultCenter] postNotificationName:MusicPlayerMgrNotificationCompletion object:nil];
		};

		// 设置后台播放模式
		AVAudioSession *audioSession=[AVAudioSession sharedInstance];
		[audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
		[audioSession setActive:YES error:nil];

		// 添加通知，拔出耳机后暂停播放
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remountControlEvent:) name:MusicPlayerMgrNotificationRemoteControlEvent object:nil];

	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
}

- (BOOL)isPlaying {
	if (audioStream) {
		return [audioStream isPlaying];
	} else {
		return NO;
	}
}

- (void)playWithUrl:url andTitle:title andArtist:artist {
	if (![audioStream url]) {
		// 没有设置过歌曲url，直接播放
		[audioStream playFromURL:[NSURL URLWithString:url]];
	} else if ([[[audioStream url] absoluteString] isEqualToString:url]) {
		// 同一首歌，暂停状态，直接调用pause恢复播放就可以了
		[audioStream pause];
	} else {
		// 切换歌曲
		[audioStream stop];
		[audioStream playFromURL:[NSURL URLWithString:url]];
	}

	[self setMediaInfo:nil andTitle:title andArtist:artist];
	[[NSNotificationCenter defaultCenter] postNotificationName:MusicPlayerMgrNotificationDidPlay object:self];
}

- (void)play {
	if ([audioStream url]) {
		[audioStream pause];

		[[NSNotificationCenter defaultCenter] postNotificationName:MusicPlayerMgrNotificationDidPlay object:self];
	}
}

- (void)pause {
	[audioStream pause];
	if ([audioStream isPlaying]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:MusicPlayerMgrNotificationDidPlay object:self];
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:MusicPlayerMgrNotificationDidPause object:self];
	}

}

- (void)stop {
	[audioStream stop];
	[[NSNotificationCenter defaultCenter] postNotificationName:MusicPlayerMgrNotificationDidPause object:self];
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
	UIEvent* event = [[notification userInfo] valueForKey:MusicPlayerMgrNotificationUserInfoKey];
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

#pragma mark - audio operations

- (void) setMediaInfo : (UIImage *) img andTitle : (NSString *) title andArtist : (NSString *) artist
{
	if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
		NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];


		[dict setObject:title forKey:MPMediaItemPropertyAlbumTitle];
		[dict setObject:artist forKey:MPMediaItemPropertyArtist];

		float totalSeconds = [audioStream duration].minute * 60.0 + [audioStream duration].second;
		[dict setObject:[NSNumber numberWithFloat:totalSeconds] forKey:MPMediaItemPropertyPlaybackDuration];
		[dict setObject:[NSNumber numberWithFloat:[audioStream currentTimePlayed].playbackTimeInSeconds] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];

		//		MPMediaItemArtwork * mArt = [[MPMediaItemArtwork alloc] initWithImage:img];
		//		[dict setObject:mArt forKey:MPMediaItemPropertyArtwork];
		[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nil;
		[[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
	}
}

- (float)getPlayPosition {
	if (![self isPlaying]) {
		return 0.0;
	} else {
		return [audioStream currentTimePlayed].position;
	}
}

@end
















