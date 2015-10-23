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
}

/**
 *  使用单例初始化
 *
 */
+ (id)standard{
    static SongListPlayer *aSongListPlayer = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        aSongListPlayer = [[self alloc] init];
    });
    return aSongListPlayer;
}

- (id)init {
	self = [super init];
	if (self) {
	}

	return self;
}

- (void)dealloc {
}

@end
















