//
//  MusicMgr.h
//  mia
//
//  Created by linyehui on 2015/10/23.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

extern NSString * const MusicMgrNotificationKey_RemoteControlEvent;
extern NSString * const MusicMgrNotificationKey_PlayerEvent;
extern NSString * const MusicMgrNotificationKey_sID;

extern NSString * const MusicMgrNotificationRemoteControlEvent;
extern NSString * const MusicMgrNotificationPlayerEvent;

typedef NS_ENUM(NSUInteger, MiaPlayerEvent) {
	MiaPlayerEventDidPlay,
	MiaPlayerEventDidPause,
	MiaPlayerEventDidCompletion
};

typedef void(^PlayWith3GOnceTimeBlock)(BOOL isAllowed);

@class ShareItem;

@interface MusicMgr : NSObject

/**
 *  使用单例初始化
 *
 */
+ (MusicMgr *)standard;

@property (assign, nonatomic) NSInteger  currentIndex;
@property (strong, nonatomic) ShareItem *currentItem;

@property (assign, nonatomic) BOOL isShufflePlay;
@property (assign, nonatomic) BOOL isLoopPlay;
@property (assign, nonatomic) BOOL isInterruption;

- (void)setPlayList:(NSArray *)playList;
- (void)setPlayListWithItem:(ShareItem *)item;

// 播放当前列表对应下标的歌曲
- (void)playWithIndex:(NSInteger)index;

// 在当前播放列表中查找item并播放
- (void)playWithItem:(ShareItem *)item;

- (void)playCurrent;
- (void)playPrevios;
- (void)playNext;

- (void)checkIsAllowToPlayWith3GOnceTimeWithBlock:(PlayWith3GOnceTimeBlock)playWith3GOnceTimeBlock;
- (BOOL)isPlayWith3GOnceTime;
- (BOOL)isPlaying;
- (BOOL)isPlayingWithUrl:(NSString *)url;
- (void)pause;
- (void)stop;
- (float)playPosition;




@end
