//
//  DetailPlayerView.h
//  mia
//
//  Created by linyehui on 2015/09/09.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShareItem;

@interface DetailPlayerView : UIView

@property (strong, nonatomic) ShareItem *shareItem;

//- (void)setShareItem:(ShareItem *)item;

- (void)playMusic;
- (void)pauseMusic;
- (void)stopMusic;

- (void)notifyMusicPlayerMgrDidPlay;
- (void)notifyMusicPlayerMgrDidPause;

@end
