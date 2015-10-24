//
//  SingleSongPlayer.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

@class MusicItem;
@class SingleSongPlayer;

@protocol SingleSongPlayerDelegate <NSObject>

- (void)singleSongPlayerDidPlay;
- (void)singleSongPlayerDidPause;
- (void)singleSongPlayerDidCompletion;

@end


@interface SingleSongPlayer : NSObject

@property (nonatomic, weak) id <SingleSongPlayerDelegate> delegate;
@property (strong, nonatomic) MusicItem * currentItem;

- (void)playWithMusicItem:(MusicItem *)item;

- (BOOL)isPlaying;
- (BOOL)isPlayingWithUrl:(NSString *)url;

- (void)pause;
- (void)stop;

- (float)playPosition;

@end
