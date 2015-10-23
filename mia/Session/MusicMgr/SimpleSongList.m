//
//  SimpleSongList.m
//  只有一首歌的歌单列表
//
//  Created by linyehui on 2015/10/23.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//
//

#import "SimpleSongList.h"
#import "SongListPlayer.h"

@interface SimpleSongList() <SongListPlayerDataSource, SongListPlayerDelegate>

@end

@implementation SimpleSongList {
}

- (id)initWithName:(NSString *)name
		   modelID:(long)modelID
			   url:(NSString*)url
			 title:(NSString *)title
			artist:(NSString *)artist {
	self = [super init];
	if (self) {
	}

	return self;
}

- (void)dealloc {
	NSLog(@"SimpleSongList dealloc");
}

#pragma mark - Delegate Methods

@end
















