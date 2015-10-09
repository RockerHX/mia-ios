//
//  DetailHeaderView.h
//  mia
//
//  Created by linyehui on 2015/09/09.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShareItem;

@protocol DetailHeaderViewDelegate

- (void)detailHeaderViewShouldLogin;

@end

@interface DetailHeaderView : UIView

@property (strong, nonatomic) ShareItem *shareItem;
@property (weak, nonatomic)id<DetailHeaderViewDelegate> customDelegate;

- (void)playMusic;
- (void)pauseMusic;
- (void)stopMusic;

- (void)notifyMusicPlayerMgrDidPlay;
- (void)notifyMusicPlayerMgrDidPause;

@end
