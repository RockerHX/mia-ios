//
//  SongListPlayer.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//
//

#import "SongListPlayer.h"

@interface SongListPlayer()

@end

@implementation SongListPlayer {
	long			_modelID;
	NSString		*_name;
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

- (BOOL)isPlayWith3GOnceTime {
	return NO;
}

- (BOOL)isPlaying {
	return NO;
}

- (BOOL)isPlayingWithUrl:(NSString *)url {
	return NO;
}

- (void)playWithModelID:(long)modelID url:(NSString*)url title:(NSString *)title artist:(NSString *)artist {
}

- (void)pause {
}

- (void)stop {
}

- (float)getPlayPosition {
	return 0.0;
}

@end
















