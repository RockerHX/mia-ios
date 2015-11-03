//
//  ProfileHeaderView.h
//  mia
//
//  Created by linyehui on 2015/09/09.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FavoriteModel;

@protocol ProfileHeaderViewDelegate

- (void)profileHeaderViewDidTouchedCover;
- (void)profileHeaderViewDidTouchedPlay;

@end

@interface ProfileHeaderView : UIView

@property (weak, nonatomic)id<ProfileHeaderViewDelegate> profileHeaderViewDelegate;
@property (assign, nonatomic) BOOL isPlaying;

- (void)updateFavoriteCount;

@end
