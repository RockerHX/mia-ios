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
	long					_modelID;
	NSString				*_name;
}

- (id)initWithModelID:(long)modelID name:(NSString *)name {
	self = [super init];
	if (self) {
		_modelID = modelID;
		_name = name;
	}

	return self;
}

- (void)dealloc {
	NSLog(@"SongListPlayer dealloc: %@", _name);
}

- (void)setUp {
	[[SingleSongPlayer standard] setDelegate:self];
}

- (void)tearDown {
	[self stop];
	[[SingleSongPlayer standard] setDelegate:nil];
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
	[[SingleSongPlayer standard] playWithMusicItem:[self currentItem]];
}

- (void)playWithMusicItem:(MusicItem *)item {
	[[SingleSongPlayer standard] playWithMusicItem:item];
}

- (BOOL)isPlayWith3GOnceTime {
	return [[SingleSongPlayer standard] isPlayWith3GOnceTime];
}

- (BOOL)isPlaying {
	return [[SingleSongPlayer standard] isPlaying];
}

- (BOOL)isPlayingWithUrl:(NSString *)url {
	return [[SingleSongPlayer standard] isPlayingWithUrl:url];
}

- (void)pause {
	[[SingleSongPlayer standard] pause];
}

- (void)stop {
	[[SingleSongPlayer standard] stop];
}

- (float)playPosition {
	return [[SingleSongPlayer standard] playPosition];
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
















