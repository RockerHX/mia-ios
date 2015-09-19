//
//  LoopPlayerView.h
//  mia
//
//  Created by linyehui on 2015/09/09.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareItem.h"
#import "PlayerView.h"
#import "PXInfiniteScrollView.h"

@protocol LoopPlayerViewDelegate

- (void)notifySwipeLeft;
- (void)notifySwipeRight;

@end

@interface LoopPlayerView : UIView <UIScrollViewDelegate>

@property (strong, nonatomic) PXInfiniteScrollView *playerScrollView;
@property (weak, nonatomic)id<LoopPlayerViewDelegate> loopPlayerViewDelegate;

- (PlayerView *)getCurrentPlayerView;
- (PlayerView *)getLeftPlayerView;
- (PlayerView *)getRightPlayerView;

- (void)notifyMusicPlayerMgrDidPlay;
- (void)notifyMusicPlayerMgrDidPause;

@end
