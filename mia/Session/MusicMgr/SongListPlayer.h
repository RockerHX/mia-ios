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
- (NSInteger)songListPlayerNextItemIndex;
- (MusicItem *)songListPlayerItemAtIndex:(NSInteger)index;
- (NSArray *)songListPlayerMusicItems;

@end

@protocol SongListPlayerDelegate <NSObject>

- (void)songListPlayerDidPlay;
- (void)songListPlayerDidPause;
- (void)songListPlayerDidCompletion;

@optional
- (void)songListPlayerShouldPlayNext;
- (void)songListPlayerShouldPlayPrevios;

@end

@interface SongListPlayer : NSObject

@property (nonatomic, weak) id <SongListPlayerDelegate> delegate;
@property (nonatomic, weak) id <SongListPlayerDataSource> dataSource;

@property (nonatomic, strong, readonly) NSArray *musicItems;

- (instancetype)initWithModelID:(long)modelID name:(NSString *)name;

- (void)setUp;
- (void)tearDown;

- (NSInteger)currentItemIndex;
- (MusicItem *)itemAtIndex:(NSInteger)index;

// 从播放器直接返回的数据，而不是数据源
- (MusicItem *)currentItem;

- (void)playCurrentItem;
- (void)playWithMusicItem:(MusicItem *)item;
- (void)playNext;
- (void)playPrevios;

- (BOOL)isPlaying;
- (BOOL)isPlayingWithUrl:(NSString *)url;
- (void)pause;
- (void)stop;
- (float)playPosition;

@end
