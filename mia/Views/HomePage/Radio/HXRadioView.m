//
//  HXRadioView.m
//  mia
//
//  Created by miaios on 15/10/17.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXRadioView.h"
#im

@implementation HXRadioView

#pragma mark - Init Methods
- (instancetype)initWithFrame:(CGRect)frame delegate:(id<HXRadioViewDelegate>)delegate {
    self = [[[NSBundle mainBundle] loadNibNamed:@"HXRadioView" owner:self options:nil] firstObject];
    self.frame = frame;
    self.delegate = delegate;
    return self;
}

#pragma mark - Event Response
- (IBAction)starButtonPressed:(UIButton *)button {
    if (_delegate && [_delegate respondsToSelector:@selector(userWouldLikeStarMusic)]) {
        [_delegate userWouldLikeStarMusic];
    }
}

- (IBAction)sharerNameButtonPressed:(UIButton *)button {
    if (_delegate && [_delegate respondsToSelector:@selector(userWouldLikeSeeSharerHomePage)]) {
        [_delegate userWouldLikeSeeSharerHomePage];
    }
}

#pragma mark - Public Methods
- (void)displayWithItem:(id)item {
    
}

@end
