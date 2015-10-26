//
//  SingleSongPlayer.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//
//

#import "SingleSongPlayer.h"
#import "FSAudioStream.h"
#import "PathHelper.h"
#import "UserSetting.h"
#import "WebSocketMgr.h"
#import "NSObject+BlockSupport.h"
#import "NSString+IsNull.h"
#import "MusicItem.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MusicMgr.h"
#import "FileLog.h"

@interface SingleSongPlayer()

@end

@implementation SingleSongPlayer {
	FSAudioStream 	*_audioStream;
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

		_audioStream.onFailure = ^(FSAudioStreamError error, NSString *errorDescription) {
			[[FileLog standard] log:@"AudioStream onFailure:%d, %@", error, errorDescription];
		};
	}
	return self;
}

- (void)dealloc {
	NSLog(@"SingleSongPlayer dealoc");
}

- (void)playWithMusicItem:(MusicItem *)item {
	[[FileLog standard] log:@"playWithMusicItem %@", item.murl];

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
	_currentItem = item;
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
	[[FileLog standard] log:@"play %@", [[_audioStream url] absoluteString]];
	if (![_audioStream url])
		return;

	if (![UserSetting isAllowedToPlayNowWithURL:[[_audioStream url] absoluteString]]) {
		[[MusicMgr standard] checkIsAllowToPlayWith3GOnceTimeWithBlock:^(BOOL isAllowed) {
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
	// 不要根据url来判断是否有歌曲在播放，因为播放完成或者stop都会把url清掉
	if ([[[_audioStream url] absoluteString] isEqualToString:url]) {
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
	[[MusicMgr standard] checkIsAllowToPlayWith3GOnceTimeWithBlock:^(BOOL isAllowed) {
		if (isAllowed) {
			[self playWithoutCheckWithUrl:url title:title artist:artist];
		}
	}];
}

#pragma mark - audio operations
- (void)setMediaInfo:(UIImage *)img andTitle:(NSString *)title andArtist:(NSString *)artist {
	if ([NSString isNull:title] || [NSString isNull:artist]) {
		return;
	}

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
















