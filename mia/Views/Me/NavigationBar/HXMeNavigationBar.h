//
//  HXMeNavigationBar.h
//  mia
//
//  Created by miaios on 16/1/27.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXMusicStateView.h"


typedef NS_ENUM(NSUInteger, HXMeNavigationAction) {
    HXMeNavigationActionMusic,
};


@class HXMeNavigationBar;


@protocol HXMeNavigationBarDelegate <NSObject>

@optional
- (void)navigationBar:(HXMeNavigationBar *)bar takeAction:(HXMeNavigationAction)action;

@end


@interface HXMeNavigationBar : UIView

@property (weak, nonatomic) IBOutlet id  <HXMeNavigationBarDelegate>delegate;

@property (weak, nonatomic) IBOutlet           UIView *backgroundView;
@property (weak, nonatomic) IBOutlet           UIView *containerView;
@property (weak, nonatomic) IBOutlet          UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet HXMusicStateView *stateView;

@property (nonatomic, assign)  CGFloat  colorAlpha;
@property (nonatomic, strong)  UIColor *color;
@property (nonatomic, strong) NSString *title;

@end
