//
//  HXProfileNavigationBar.h
//  mia
//
//  Created by miaios on 16/1/27.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, HXProfileNavigationAction) {
    HXProfileNavigationActionBack,
    HXProfileNavigationActionMusic,
};


@class HXMusicStateView;
@class HXProfileNavigationBar;


@protocol HXProfileNavigationBarDelegate <NSObject>

@optional
- (void)navigationBar:(HXProfileNavigationBar *)bar takeAction:(HXProfileNavigationAction)action;

@end


@interface HXProfileNavigationBar : UIView

@property (weak, nonatomic) IBOutlet id  <HXProfileNavigationBarDelegate>delegate;

@property (weak, nonatomic) IBOutlet           UIView *backgroundView;
@property (weak, nonatomic) IBOutlet           UIView *containerView;
@property (weak, nonatomic) IBOutlet          UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet         UIButton *backButton;
@property (weak, nonatomic) IBOutlet HXMusicStateView *stateView;

@property (nonatomic, assign)  CGFloat  colorAlpha;
@property (nonatomic, strong) NSString *title;

- (IBAction)backButtonPressed;

@end
