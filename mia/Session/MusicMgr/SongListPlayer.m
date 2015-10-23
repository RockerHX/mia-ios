//
//  SongListPlayer.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//
//

#import "SongListPlayer.h"
#import "SingleSongPlayer.h"

@interface SongListPlayer() <SingleSongPlayerDelegate>

@end

@implementation SongListPlayer {
	SingleSongPlayer		*_player;
	long					_modelID;
	NSString				*_name;
}

- (id)initWithModelID:(long)modelID name:(NSString *)name {
	self = [super init];
	if (self) {
		_modelID = modelID;
		_name = name;

		_player = [[SingleSongPlayer alloc] init];
		_player.delegate = self;
	}

	return self;
}

- (void)dealloc {
	NSLog(@"SongListPlayer dealloc: %@", _name);
}

- (NSInteger)currentItemIndex {
	return [_dataSource songListPlayerCurrentItemIndex];
}

- (MusicItem *)currentItem {
	return [_dataSource songListPlayerItemAtIndex:[_dataSource songListPlayerCurrentItemIndex]];
}

- (MusicItem *)itemAtIndex:(NSInteger)index {
	return [_dataSource songListPlayerItemAtIndex:index];
}

- (void)playCurrentItem {
	[_player playWithMusicItem:[self currentItem]];
}

- (BOOL)isPlayWith3GOnceTime {
	return [_player isPlayWith3GOnceTime];
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
	[_player pause];
}

- (float)playPosition {
	return [_player playPosition];
}

#pragma mark - SingleSongPlayerDelegate
- (void)singleSongPlayerDidPlay {
	if (_delegate) {
		[_delegate songListPlayerDidPlay];
	}
}

- (void)singleSongPlayerDidPause {
	if (_delegate) {
		[_delegate songListPlayerDidPause];
	}
}

- (void)singleSongPlayerDidCompletion {
	if (_delegate) {
		[_delegate songListPlayerDidCompletion];
	}
}

@end
















