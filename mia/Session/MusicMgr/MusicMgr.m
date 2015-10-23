//
//  MusicMgr.m
//  mia
//
//  Created by linyehui on 2015/10/23.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//
//

#import "MusicMgr.h"
#import "SingleSongPlayer.h"
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

- (void)setSongListPlayer:(SongListPlayer *)player {
	[self tearDown];
	[self setUp:player];
}

#pragma mark - Private Methods

- (void)setUp:(SongListPlayer *)player {
	// TODO
	_listPlayer = player;
}

- (void)tearDown {
	// TODO
}

#pragma mark - Player Methods

- (void)playCurrentItem {
	[_listPlayer playCurrentItem];
}

- (BOOL)isPlayWith3GOnceTime {
	return [_listPlayer isPlayWith3GOnceTime];
}

- (BOOL)isPlaying {
	return [_listPlayer isPlaying];;
}

- (BOOL)isPlayingWithUrl:(NSString *)url {
	return [_listPlayer isPlayingWithUrl:url];
}

- (void)pause {
	[_listPlayer pause];
}

- (void)stop {
	[_listPlayer stop];
}

- (float)playPosition {
	return [_listPlayer playPosition];
}

@end






