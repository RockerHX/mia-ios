//
//  HXHomePageWaveView.m
//  mia
//
//  Created by miaios on 15/10/24.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXHomePageWaveView.h"

@implementation HXHomePageWaveView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initConfig];
    [self viewConfig];
}

#pragma mark - Layout Methods
- (void)layoutSubviews {
    _waveView.frame = self.bounds;
}

#pragma mark - Config Methods
- (void)initConfig {
    
    _waveView = [[HXWaveView alloc] initWithFrame:self.bounds];
    // 配置波浪颜色，波浪高度以及波动运动速度
    _waveView.tintColor = [UIColor colorWithRed:68.0f/255.0f green:209.0f/255.0f blue:192.0f/255.0f alpha:1.0f];
    _waveView.percent = 0.4f;
    _waveView.speed = 3.0f;
}

- (void)viewConfig {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:_waveView];
}

#pragma mark - Public Methods
// 波浪退出动画
- (void)waveMoveDownAnimation:(void (^)(void))completion {
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.8f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        CGRect bounds = strongSelf.bounds;
        strongSelf.waveView.frame = (CGRect) {
            bounds.origin.x, bounds.size.height,
            bounds.size.width, bounds.size.height
        };
    } completion:^(BOOL finished) {
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf.waveView stopAnimating];
        if (completion) {
            completion();
        }
    }];
}

// 波浪升起动画
- (void)waveMoveUpAnimation:(void (^)(void))completion {
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf.waveView.frame = strongSelf.bounds;
    } completion:^(BOOL finished) {
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf.waveView stopAnimating];
        if (completion) {
            completion();
        }
    }];
}

- (void)reset {
    [_waveView stopAnimating];
    _waveView.frame = self.bounds;
}

@end
