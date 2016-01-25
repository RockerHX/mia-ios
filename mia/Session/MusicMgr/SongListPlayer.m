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
#import "SongPreloader.h"
#import "NSObject+BlockSupport.h"

@interface SongListPlayer() <SingleSongPlayerDelegate, SongPreloaderDelegate>

@end

@implementation SongListPlayer {
	SingleSongPlayer		*_player;
	SongPreloader			*_preloader;
	long					_modelID;
	NSString				*_name;
}

- (id)initWithModelID:(long)modelID name:(NSString *)name {
	self = [super init];
	if (self) {
		_player = [[SingleSongPlayer alloc] init];
		_preloader = [[SongPreloader alloc] init];
		_preloader.delegate = self;
		_modelID = modelID;
		_name = name;
	}

	return self;
}

- (void)dealloc {
	NSLog(@"SongListPlayer dealloc: %@", _name);
}

- (void)setUp {
	[_player setDelegate:self];
}

- (void)tearDown {
	[self stop];
	[_player setDelegate:nil];
}

- (NSInteger)currentItemIndex {
	return [_dataSource songListPlayerCurrentItemIndex];
}

- (NSInteger)nextItemIndex {
	return [_dataSource songListPlayerNextItemIndex];
}

- (MusicItem *)itemAtIndex:(NSInteger)index {
	return [_dataSource songListPlayerItemAtIndex:index];
}

- (MusicItem *)currentItem {
	return _player.currentItem;
}

- (void)playCurrentItem {
	[_player playWithMusicItem:[self currentItem]];
}

- (void)playWithMusicItem:(MusicItem *)item {
	[_preloader stop];
	[_player playWithMusicItem:item];
}

- (void)playNext {
	if (_delegate && [_delegate respondsToSelector:@selector(songListPlayerShouldPlayNext)]) {
		[_delegate songListPlayerShouldPlayNext];
	}
}

- (void)playPrevios {
	if (_delegate && [_delegate respondsToSelector:@selector(songListPlayerShouldPlayPrevios)]) {
		[_delegate songListPlayerShouldPlayPrevios];
	}
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

- (void)singleSongPlayerDidBufferStream {
	[self bs_performBlock:^{
		NSLog(@"delayPreloader");
		[_preloader preloadWithMusicItem:[_dataSource songListPlayerItemAtIndex:[_dataSource songListPlayerNextItemIndex]]];
	} afterDelay:30.0f];
}

- (void)singleSongPlayerDidFailure {
	if (_delegate) {
		[_delegate songListPlayerDidPause];
	}
}

- (BOOL)songPreloaderIsPlayerLoadedThisUrl:(NSString *)url {
	return [_player.currentItem.murl isEqualToString:url];
}

@end
















