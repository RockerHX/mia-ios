//
//  PlayerView.h
//  mia
//
//  Created by linyehui on 2015/09/09.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShareItem;

@protocol PlayerViewDelegate

- (void)playerViewPlayCompletion;

@end

@interface PlayerView : UIView

@property (strong, nonatomic) ShareItem *shareItem;
@property (weak, nonatomic)id<PlayerViewDelegate> customDelegate;

//- (void)setShareItem:(ShareItem *)item;

- (void)playMusic;
- (void)pauseMusic;
- (void)stopMusic;

@end
