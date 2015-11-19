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
#import <AVFoundation/AVFoundation.h>
#import "PathHelper.h"
#import "UserSetting.h"
#import "WebSocketMgr.h"
#import "NSObject+BlockSupport.h"
#import "NSString+IsNull.h"
#import "MusicItem.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MusicMgr.h"
#import "FileLog.h"
#import "SDWebImageDownloader.h"

@interface SingleSongPlayer()

@end

@implementation SingleSongPlayer {
	FSAudioStream 		*_audioStream;
	FSAudioStreamState	_audioState;
}

- (id)init {
	self = [super init];
	if (self) {
		// init audioStream
		FSStreamConfiguration *defaultConfiguration = [[FSStreamConfiguration alloc] init];
		defaultConfiguration.cacheDirectory = [PathHelper playCacheDir];
		defaultConfiguration.maxDiskCacheSize = 209715200;	// 200MB
		_audioStream = [[FSAudioStream alloc] initWithConfiguration:defaultConfiguration];
		_audioStream.strictContentTypeChecking = NO;
		_audioStream.defaultContentType = @"audio/mpeg";

		__weak SingleSongPlayer *weakPlayer = self;
		_audioStream.onCompletion = ^() {
			__strong SingleSongPlayer *strongPlayer = weakPlayer;
			[strongPlayer stop];
			if ([strongPlayer delegate]) {
				[[strongPlayer delegate] singleSongPlayerDidCompletion];
			}
		};
		_audioStream.onStateChange = ^(FSAudioStreamState state) {
			NSLog(@"FSAudioStreamState change:%u", state);
			__strong SingleSongPlayer *strongPlayer = weakPlayer;
			strongPlayer->_audioState = state;

			if (kFSAudioStreamEndOfFile == state) {
				if ([strongPlayer delegate]) {
					[[strongPlayer delegate] singleSongPlayerDidBufferStream];
				}
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
	[[FileLog standard] log:@"playWithMusicItem %@, %@", item.name, item.murl];

	if ([self isPlayingWithUrl:item.murl]) {
		// 同一个模块再次播放同一首歌，什么都不做
		NSLog(@"play the same song in the same model, play will be ignored.");
		return;
	}

	if (![UserSetting isAllowedToPlayNowWithURL:item.murl]) {
		[self checkBeforePlayWithMusicItem:item];
		return;
	}

	[self playWithoutCheckWithUrl:item.murl title:item.name artist:item.singerName cover:item.purl];
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
	[[FileLog standard] log:@"play: %@", [[_audioStream url] absoluteString]];
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

	NSLog(@"play - resume play from pause");
	[_audioStream pause];

	if (_delegate) {
		[_delegate singleSongPlayerDidPlay];
	}
}

- (void)pause {
	[[FileLog standard] log:@"pause: %@", [[_audioStream url] absoluteString]];
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

- (void)playWithoutCheckWithUrl:(NSString*)url title:(NSString *)title artist:(NSString *)artist cover:(NSString *)cover {
	if ([[[_audioStream url] absoluteString] isEqualToString:url]) {
		// 不要根据url来判断是否有歌曲在播放，因为播放完成或者stop都会把url清掉
		// 同一首歌，暂停状态，直接调用pause恢复播放就可以了
		if (_audioState == kFsAudioStreamStopped) {
			NSLog(@"resume music from interruption.");
			[self playAnotherWirUrl:url];
		} else if ([_audioStream isPlaying]) {
			NSLog(@"resume music from pause error, stop and play again.");
			[self playAnotherWirUrl:url];
		} else {
			NSLog(@"playWithUrl - resume play from pause");
			[_audioStream pause];
		}
	} else {
		// 切换歌曲
		[self playAnotherWirUrl:url];
	}

	[[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:cover]
														  options:0 progress:nil completed:
	 ^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
		if (image && finished) {
			[self setMediaInfo:image andTitle:title andArtist:artist];
		} else {
			[self setMediaInfo:nil andTitle:title andArtist:artist];
		}
	}];

	if (_delegate) {
		[_delegate singleSongPlayerDidPlay];
	}
}

- (void)playAnotherWirUrl:(NSString *)url {
	NSLog(@"stop - stop before playAnotherWirUrl");
	[_audioStream stop];
	[self bs_performBlock:^{
		NSLog(@"delayPlayHandlerWithUrl");
		[_audioStream playFromURL:[NSURL URLWithString:url]];
	} afterDelay:0.5f];
}

- (void)checkBeforePlayWithMusicItem:(MusicItem *)item {
	[[MusicMgr standard] checkIsAllowToPlayWith3GOnceTimeWithBlock:^(BOOL isAllowed) {
		if (isAllowed) {
			[self playWithoutCheckWithUrl:item.murl title:item.name artist:item.singerName cover:item.purl];
		}
	}];
}

#pragma mark - audio operations
- (void)setMediaInfo:(UIImage *)coverImage andTitle:(NSString *)title andArtist:(NSString *)artist {
	if ([NSString isNull:title] || [NSString isNull:artist]) {
		return;
	}

	dispatch_sync(dispatch_get_main_queue(), ^ {
		if (!NSClassFromString(@"MPNowPlayingInfoCenter"))
			return ;

		NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];

		[dict setObject:title forKey:MPMediaItemPropertyAlbumTitle];
		[dict setObject:artist forKey:MPMediaItemPropertyArtist];

		float totalSeconds = [_audioStream duration].minute * 60.0 + [_audioStream duration].second;
		[dict setObject:[NSNumber numberWithFloat:totalSeconds] forKey:MPMediaItemPropertyPlaybackDuration];
		[dict setObject:[NSNumber numberWithFloat:[_audioStream currentTimePlayed].playbackTimeInSeconds] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];

		if (coverImage) {
			MPMediaItemArtwork * mArt = [[MPMediaItemArtwork alloc] initWithImage:coverImage];
			[dict setObject:mArt forKey:MPMediaItemPropertyArtwork];
		}
		
		[[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];

	});
}


@end
















