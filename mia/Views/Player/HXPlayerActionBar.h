//
//  HXPlayerActionBar.h
//  mia
//
//  Created by miaios on 15/11/30.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HXPlayerActionBarAction) {
    HXPlayerActionBarActionPrevious,
    HXPlayerActionBarActionPlay,
    HXPlayerActionBarActionPause,
    HXPlayerActionBarActionNext
};

@class HXPlayerActionBar;

@protocol HXPlayerActionBarDelegate <NSObject>

@required
- (void)actionBar:(HXPlayerActionBar *)bar action:(HXPlayerActionBarAction)action;

@end

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000

IB_DESIGNABLE

#endif

@interface HXPlayerActionBar : UIView

@property (weak, nonatomic) IBOutlet id  <HXPlayerActionBarDelegate>delegate;

- (IBAction)previousButtonPressed;
- (IBAction)playButtonPressed;
- (IBAction)nextButtonPressed;

@end