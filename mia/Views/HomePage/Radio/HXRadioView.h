//
//  HXRadioView.h
//  mia
//
//  Created by miaios on 15/10/17.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShareItem;
@class HXRadioView;

typedef NS_ENUM(NSUInteger, HXRadioViewAction) {
    HXRadioViewActionPlay,
    HXRadioViewActionPause,
    HXRadioViewActionContentTaped
};

@protocol HXRadioViewDelegate <NSObject>

@optional
- (void)radioViewDidLoad:(HXRadioView *)radioView;
- (void)radioViewStarTapedNeedLogin:(HXRadioView *)radioView;
- (void)radioView:(HXRadioView *)radioView takeAction:(HXRadioViewAction)action;

@end


@class HXRadioShareInfoView;

@interface HXRadioView : UIView

@property (weak, nonatomic) IBOutlet          id  <HXRadioViewDelegate>delegate;

@property (weak, nonatomic) IBOutlet              UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet              UILabel *songerNameLabel;
@property (weak, nonatomic) IBOutlet          UIImageView *frontCoverView;
@property (weak, nonatomic) IBOutlet       UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet             UIButton *playButton;
@property (weak, nonatomic) IBOutlet             UIButton *starButton;
@property (weak, nonatomic) IBOutlet HXRadioShareInfoView *shareInfoView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverWidthConstraint;

- (IBAction)coverTaped;
- (IBAction)playButtonPressed:(UIButton *)button;
- (IBAction)starButtonPressed:(UIButton *)button;

+ (instancetype)initWithFrame:(CGRect)frame delegate:(id<HXRadioViewDelegate>)delegate;
- (void)displayWithItem:(ShareItem *)item;

@end
