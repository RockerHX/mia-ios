//
//  MusicMgr.h
//  mia
//
//  Created by linyehui on 2015/10/23.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

extern NSString * const MusicMgrNotificationKey_Msg;
extern NSString * const MusicMgrNotificationRemoteControlEvent;

typedef void(^PlayWith3GOnceTimeBlock)(BOOL isAllowed);

@class SongListPlayer;

@interface MusicMgr : NSObject

/**
 *  使用单例初始化
 *
 */
+ (id)standard;

@property (strong, nonatomic) SongListPlayer *currentPlayer;

- (BOOL)isPlayWith3GOnceTime;
- (BOOL)isPlayingWithUrl:(NSString *)url;
- (void)pause;

- (void)checkIsAllowToPlayWith3GOnceTimeWithBlock:(PlayWith3GOnceTimeBlock)playWith3GOnceTimeBlock;

@end
