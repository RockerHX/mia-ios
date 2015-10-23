//
//  SingleSongPlayer.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

extern NSString * const MusicMgrNotificationKey_Msg;
extern NSString * const MusicMgrNotificationRemoteControlEvent;

@class MusicItem;
@class SingleSongPlayer;

@protocol SingleSongPlayerDelegate <NSObject>

- (void)singleSongPlayerDidPlay;
- (void)singleSongPlayerDidPause;
- (void)singleSongPlayerDidCompletion;

@end


@interface SingleSongPlayer : NSObject

@property (nonatomic, weak) id <SingleSongPlayerDelegate> delegate;

- (void)playWithMusicItem:(MusicItem *)item;

- (BOOL)isPlayWith3GOnceTime;
- (BOOL)isPlaying;
- (BOOL)isPlayingWithUrl:(NSString *)url;
- (void)pause;
- (void)stop;
- (float)playPosition;

@end
