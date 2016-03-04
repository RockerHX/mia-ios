//
//  HXMeNavigationBar.m
//  mia
//
//  Created by miaios on 16/1/27.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXMeNavigationBar.h"
#import "HXXib.h"


@interface HXMeNavigationBar () <
HXMusicStateViewDelegate
>
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
    _color = [UIColor whiteColor];
    _stateView.stateIcon.image = [_stateView.stateIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _stateView.stateIcon.tintColor = [UIColor whiteColor];
}

- (void)viewConfigure {
    _containerView.backgroundColor = [UIColor clearColor];
}

#pragma mark - Setter And Getter
- (void)setColorAlpha:(CGFloat)colorAlpha {
    _colorAlpha = colorAlpha;
    
    _backgroundView.alpha = colorAlpha;
    _titleLabel.alpha = colorAlpha;
    _color = [UIColor colorWithWhite:(1 - colorAlpha) alpha:1.0f];
    _titleLabel.textColor = _color;
    _stateView.stateIcon.tintColor = _color;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    _titleLabel.text = title;
}

#pragma mark - HXMusicStateViewDelegate Methods
- (void)musicStateViewTaped:(HXMusicStateView *)stateView {
    if (_delegate && [_delegate respondsToSelector:@selector(navigationBar:takeAction:)]) {
        [_delegate navigationBar:self takeAction:HXMeNavigationActionMusic];
    }
}

@end
