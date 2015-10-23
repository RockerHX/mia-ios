//
//  SongListPlayer.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "MusicItem.h"

@protocol SongListPlayerDataSource <NSObject>

- (NSInteger)songListPlayerCurrentItemIndex;
- (MusicItem *)songListPlayerItemAtIndex:(NSInteger)index;

@end

@protocol SongListPlayerDelegate <NSObject>

- (void)songListPlayerDidPlay;
- (void)songListPlayerDidPause;
- (void)songListPlayerDidCompletion;

@end

@interface SongListPlayer : NSObject

@property (nonatomic, weak) id <SongListPlayerDelegate> delegate;
@property (nonatomic, weak) id <SongListPlayerDataSource> dataSource;

- (id)initWithModelID:(long)modelID name:(NSString *)name;

- (NSInteger)currentItemIndex;
- (MusicItem *)currentItem;
- (MusicItem *)itemAtIndex:(NSInteger)index;

- (void)playCurrentItem;
- (BOOL)isPlayWith3GOnceTime;
- (BOOL)isPlaying;
- (BOOL)isPlayingWithUrl:(NSString *)url;
- (void)pause;
- (void)stop;
- (float)playPosition;

@end
