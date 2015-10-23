//
//  SongListPlayer.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

@protocol SongListPlayerDataSource <NSObject>

@end

@protocol SongListPlayerDelegate <NSObject>

@end

@interface SongListPlayer : NSObject

@property (nonatomic, weak) id <SongListPlayerDelegate> delegate;
@property (nonatomic, weak) id <SongListPlayerDataSource> dataSource;

- (id)initWithModelID:(long)modelID name:(NSString *)name;

- (BOOL)isPlayWith3GOnceTime;
- (BOOL)isPlaying;
- (BOOL)isPlayingWithUrl:(NSString *)url;
- (void)playWithModelID:(long)modelID url:(NSString*)url title:(NSString *)title artist:(NSString *)artist;
- (void)pause;
- (void)stop;
- (float)getPlayPosition;

@end
