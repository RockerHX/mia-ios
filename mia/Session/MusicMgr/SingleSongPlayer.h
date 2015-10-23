//
//  SingleSongPlayer.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

@interface SingleSongPlayer : NSObject

/**
 *  使用单例初始化
 *
 */
+(id)standard;

// 不同模块都可以调用播放器，需要记录当前使用播放器的是哪个模块
// 使用模块的实例对象地址来做ModelID
// 如果用枚举值的话很容易忘记修改
// linyehui
@property (assign, nonatomic) long currentModelID;

- (BOOL)isPlayWith3GOnceTime;
- (BOOL)isPlaying;
- (BOOL)isPlayingWithUrl:(NSString *)url;
- (void)playWithModelID:(long)modelID url:(NSString*)url title:(NSString *)title artist:(NSString *)artist;
- (void)pause;
- (void)stop;

- (float)getPlayPosition;

@end