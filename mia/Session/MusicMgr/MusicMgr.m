//
//  MusicMgr.m
//  mia
//
//  Created by linyehui on 2015/10/23.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//
//

#import "MusicMgr.h"
#import "SongListPlayer.h"

@interface MusicMgr()

@end

@implementation MusicMgr {
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
	}
	return self;
}

- (void)dealloc {
}

#pragma mark - Public Methods

- (void)setSongListPlayer:(SongListPlayer *)songListPlayer {
	[self tearDown];
	[self setUp:songListPlayer];
}

#pragma mark - Private Methods

- (void)setUp:(SongListPlayer *)songListPlayer {
	// TODO
	_songListPlayer = songListPlayer;
}

- (void)tearDown {
	// TODO
}

#pragma mark - Player Methods

- (BOOL)isPlayWith3GOnceTime {
	return [_songListPlayer isPlayWith3GOnceTime];
}

- (BOOL)isPlaying {
	return [_songListPlayer isPlaying];
}

- (BOOL)isPlayingWithUrl:(NSString *)url {
	return [_songListPlayer isPlayingWithUrl:url];
}

- (void)playWithModelID:(long)modelID url:(NSString*)url title:(NSString *)title artist:(NSString *)artist {
	[_songListPlayer playWithModelID:modelID url:url title:title artist:artist];
}

- (void)pause {
	[_songListPlayer pause];
}

- (void)stop {
	[_songListPlayer pause];
}

- (float)getPlayPosition {
	return [_songListPlayer getPlayPosition];
}

@end






