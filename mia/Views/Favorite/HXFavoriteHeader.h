//
//  HXFavoriteHeader.h
//  mia
//
//  Created by miaios on 15/11/27.
//  Copyright © 2015年 miaios. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HXFavoriteHeaderAction) {
    HXFavoriteHeaderActionPlay,
    HXFavoriteHeaderActionEdit
};

typedef NS_ENUM(BOOL, HXFavoriteHeaderState) {
    HXFavoriteHeaderStatePlay  = YES,
    HXFavoriteHeaderStatePause = NO
};

@class HXFavoriteHeader;

@protocol HXFavoriteHeaderDelegate <NSObject>

@required
- (void)favoriteHeader:(HXFavoriteHeader *)header action:(HXFavoriteHeaderAction)action;

@end

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000

IB_DESIGNABLE

#endif

@interface HXFavoriteHeader : UIView

@property (weak, nonatomic) IBOutlet       id  <HXFavoriteHeaderDelegate>delegate;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet  UILabel *countLabel;

@property (nonatomic, assign) HXFavoriteHeaderState  playState;

- (IBAction)playButtonPressed;
- (IBAction)editButtonPressed;

@end
