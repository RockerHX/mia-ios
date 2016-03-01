//
//  HXMeNavigationBar.m
//  mia
//
//  Created by miaios on 16/1/27.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXMeNavigationBar.h"
#import "HXXib.h"

@interface HXMeNavigationBar ()

@property (weak, nonatomic) IBOutlet   UIView *backgroundView;
@property (weak, nonatomic) IBOutlet   UIView *containerView;
@property (weak, nonatomic) IBOutlet  UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *musicButton;

- (IBAction)backButtonPressed;
- (IBAction)musicButtonPressed;

@end

@implementation HXMeNavigationBar

HXXibImplementation

#pragma mark - Load Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
//    [_backButton setImage:[[_backButton imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_musicButton setImage:[[_musicButton imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
//    [_backButton setTintColor:[UIColor whiteColor]];
    [_musicButton setTintColor:[UIColor whiteColor]];
}

- (void)viewConfigure {
    _containerView.backgroundColor = [UIColor clearColor];
}

#pragma mark - Setter And Getter
- (void)setColorAlpha:(CGFloat)colorAlpha {
    _colorAlpha = colorAlpha;
    
    _backgroundView.alpha = colorAlpha;
    _titleLabel.alpha = colorAlpha;
    UIColor *color = [UIColor colorWithWhite:(1 - colorAlpha) alpha:1.0f];
    _titleLabel.textColor = color;
//    [_backButton setTintColor:color];
    [_musicButton setTintColor:color];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    _titleLabel.text = title;
}

#pragma mark - Event Response
- (IBAction)backButtonPressed {
    ;
}

- (IBAction)musicButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(navigationBar:takeAction:)]) {
        [_delegate navigationBar:self takeAction:HXMeNavigationBarMusic];
    }
}

@end
