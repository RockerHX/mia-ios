//
//  MusicMgr.h
//  mia
//
//  Created by linyehui on 2015/10/23.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

extern NSString * const MusicMgrNotificationKey_Msg;
extern NSString * const MusicMgrNotificationKey_sID;
extern NSString * const MusicMgrNotificationKey_Event;

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

@property (strong, nonatomic) NSMutableArray 	*playList;
@property (strong, nonatomic) ShareItem 		*currentItem;
@property (strong, nonatomic) ShareItem 		*nextItem;
@property (assign, nonatomic) NSInteger 		currentIndex;

@property (assign , nonatomic) BOOL				shufflePlay;
@property (assign, nonatomic) BOOL				isInterruption;

- (void)checkIsAllowToPlayWith3GOnceTimeWithBlock:(PlayWith3GOnceTimeBlock)playWith3GOnceTimeBlock;

- (BOOL)isPlayWith3GOnceTime;
- (void)playCurrentItem;
- (void)playWithItem:(ShareItem *)item;
- (void)playNext;
- (void)playPrevios;
- (BOOL)isPlaying;
- (BOOL)isPlayingWithUrl:(NSString *)url;
- (void)pause;
- (void)stop;
- (float)playPosition;




@end
