//
//  MIATexAlertView.h
//  mia
//
//  Created by HongBin Lin on 14-10-8.
//  Copyright (c) 2014年 duowan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MIATexAlertViewDelegate

@optional
- (void)dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface MIATexAlertView : UIView<MIATexAlertViewDelegate>

@property (nonatomic, retain) UIView *parentView;
@property (nonatomic, retain) UIView *dialogView;
@property (nonatomic, retain) UIView *containerView;

@property (nonatomic, assign) id<MIATexAlertViewDelegate> delegate;
@property (nonatomic, retain) NSArray *buttonTitles;
@property (nonatomic, assign) BOOL useMotionEffects;

@property (copy) void (^onButtonTouchUpInside)(MIATexAlertView *alertView, int buttonIndex) ;

- (id)init;

- (id)initWithParentView: (UIView *)_parentView __attribute__ ((deprecated));

- (void)show;
- (void)close;

- (void)dialogButtonTouchUpInside:(id)sender;
- (void)setOnButtonTouchUpInside:(void (^)(MIATexAlertView *alertView, int buttonIndex))onButtonTouchUpInside;

- (void)deviceOrientationDidChange: (NSNotification *)notification;
- (void)dealloc;
@end
