//
//  HXPlayerTopBar.h
//  mia
//
//  Created by miaios on 15/11/30.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HXPlayerTopBarAction) {
    HXPlayerTopBarActionBack,
    HXPlayerTopBarActionList
};

@class HXPlayerTopBar;

@protocol HXPlayerTopBarDelegate <NSObject>

@required
- (void)topBar:(HXPlayerTopBar *)bar action:(HXPlayerTopBarAction)action;

@end

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000

IB_DESIGNABLE

#endif

@interface HXPlayerTopBar : UIView

@property (weak, nonatomic) IBOutlet id  <HXPlayerTopBarDelegate>delegate;

- (IBAction)backButtonPressed;
- (IBAction)listButtonPressed;

@end
