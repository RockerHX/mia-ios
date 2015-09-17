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

@interface LoopPlayerView : UIView

- (PlayerView *)getCurrentPlayerView;
- (PlayerView *)getPrevPlayerView;
- (PlayerView *)getNextPlayerView;

- (void)setShareItem:(ShareItem *)item;
- (void)notifyMusicPlayerMgrDidPlay;
- (void)notifyMusicPlayerMgrDidPause;

@end
