//
//  MusicMgr.h
//  mia
//
//  Created by linyehui on 2015/10/23.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

@class SongListPlayer;

@interface MusicMgr : NSObject

/**
 *  使用单例初始化
 *
 */
+ (id)standard;

@property (strong, nonatomic) SongListPlayer *listPlayer;

// TODO linyehui
//- (void)playCurrentItem;
//- (BOOL)isPlayWith3GOnceTime;
//- (BOOL)isPlaying;
- (BOOL)isPlayingWithUrl:(NSString *)url;
//- (void)pause;
//- (void)stop;
//- (float)playPosition;

@end
