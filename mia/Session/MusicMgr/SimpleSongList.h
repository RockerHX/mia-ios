//
//  SimpleSongList.h
//  只有一首歌的歌单列表
//
//  Created by linyehui on 2015/10/23.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

@protocol SongListPlayerDelegate;

@interface SimpleSongList : NSObject

@property (nonatomic, weak) id <SongListPlayerDelegate> delegate;

- (id)initWithName:(NSString *)name
		   modelID:(long)modelID
			   url:(NSString*)url
			 title:(NSString *)title
			artist:(NSString *)artist;

@end
