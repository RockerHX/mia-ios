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

- (void)setCurrentPlayer:(SongListPlayer *)player {
	[_currentPlayer tearDown];
	_currentPlayer = player;
	[player setUp];
}

#pragma mark - Private Methods

#pragma mark - Player Methods

- (void)playCurrentItem {
	[_currentPlayer playCurrentItem];
}

- (BOOL)isPlayWith3GOnceTime {
	return [_currentPlayer isPlayWith3GOnceTime];
}

- (BOOL)isPlaying {
	return [_currentPlayer isPlaying];;
}

- (BOOL)isPlayingWithUrl:(NSString *)url {
	return [_currentPlayer isPlayingWithUrl:url];
}

- (void)pause {
	[_currentPlayer pause];
}

- (void)stop {
	[_currentPlayer stop];
}

- (float)playPosition {
	return [_currentPlayer playPosition];
}

@end






