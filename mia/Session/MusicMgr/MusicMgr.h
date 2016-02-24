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

@property (strong, nonatomic) NSArray 			*playList;
@property (strong, nonatomic) ShareItem 		*currentItem;
@property (assign, nonatomic) NSInteger 		currentIndex;

@property (assign , nonatomic) BOOL				isShufflePlay;
@property (assign , nonatomic) BOOL				isLoopPlay;
@property (assign, nonatomic) BOOL				isInterruption;

- (void)checkIsAllowToPlayWith3GOnceTimeWithBlock:(PlayWith3GOnceTimeBlock)playWith3GOnceTimeBlock;

- (BOOL)isPlayWith3GOnceTime;

- (void)playWithIndex:(NSInteger)index;
- (void)playWithItem:(ShareItem *)item;
- (void)playCurrent;
- (void)playPrevios;
- (void)playNext;

- (BOOL)isPlaying;
- (BOOL)isPlayingWithUrl:(NSString *)url;
- (void)pause;
- (void)stop;
- (float)playPosition;




@end
