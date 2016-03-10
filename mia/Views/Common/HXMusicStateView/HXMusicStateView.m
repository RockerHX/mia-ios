//
//  HXMusicStateView.m
//  mia
//
//  Created by miaios on 16/3/4.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXMusicStateView.h"
#import "HXXib.h"


@implementation HXMusicStateView {
    NSArray *_animationImages;
}

HXXibImplementation

#pragma mark - Load Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    NSMutableArray *imgaes = [[NSMutableArray alloc] initWithCapacity:30];
    for (NSUInteger index = 0; index < 30; index++ ) {
        [imgaes addObject:[UIImage imageNamed:@(index).stringValue]];
    }
    _animationImages = imgaes.copy;
}

- (void)viewConfigure {
    _containerView.backgroundColor = [UIColor clearColor];
    _stateIcon.animationImages = _animationImages;
    _stateIcon.animationDuration = 2.0f;
}

#pragma mark - Property
- (void)setStyle:(HXMusicStyle)style {
    _style = style;
    
    NSString *imageName = nil;
    switch (style) {
        case HXMusicStyleBlack: {
            imageName = @"CM-MuisIcon-Black";
            break;
        }
        case HXMusicStyleWhite: {
            imageName = @"CM-MuisIcon-White";
            break;
        }
    }
    _stateIcon.image = [UIImage imageNamed:imageName];
}

- (void)setState:(HXMusicState)state {
    _state = state;
    switch (state) {
        case HXMusicStatePlay: {
            [_stateIcon startAnimating];
            break;
        }
        case HXMusicStateStop: {
            [_stateIcon stopAnimating];
            break;
        }
    }
}

#pragma mark - Event Response
- (IBAction)tapGesture {
    if (_delegate && [_delegate respondsToSelector:@selector(musicStateViewTaped:)]) {
        [_delegate musicStateViewTaped:self];
    }
}

@end
