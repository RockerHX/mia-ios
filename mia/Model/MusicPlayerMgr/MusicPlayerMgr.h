//
//  MusicPlayerMgr.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

//typedef void(^RequestGetBannerSceneSuccess)();

extern NSString * const MusicPlayerMgrNotificationUserInfoKey;

extern NSString * const MusicPlayerMgrNotificationRemoteControlEvent;
extern NSString * const MusicPlayerMgrNotificationDidPlay;
extern NSString * const MusicPlayerMgrNotificationDidPause;

@interface MusicPlayerMgr : NSObject

/**
 *  使用单例初始化
 *
 */
+(id)standarMusicPlayerMgr;

- (BOOL)isPlaying;
- (void)playWithUrl:url andTitle:title andArtist:artist;
- (void)play;
- (void)pause;

@end
