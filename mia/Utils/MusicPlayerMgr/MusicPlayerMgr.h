//
//  MusicPlayerMgr.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

extern NSString * const MusicPlayerMgrNotificationKey_Msg;
extern NSString * const MusicPlayerMgrNotificationKey_ModelID;

extern NSString * const MusicPlayerMgrNotificationRemoteControlEvent;
extern NSString * const MusicPlayerMgrNotificationDidPlay;
extern NSString * const MusicPlayerMgrNotificationDidPause;
extern NSString * const MusicPlayerMgrNotificationCompletion;

@interface MusicPlayerMgr : NSObject

/**
 *  使用单例初始化
 *
 */
+(id)standard;

- (BOOL)isPlaying;
- (void)playWithModelID:(long)modelID url:(NSString*)url title:(NSString *)title artist:(NSString *)artist;
- (void)pause;
- (void)stop;

- (float)getPlayPosition;

@end
