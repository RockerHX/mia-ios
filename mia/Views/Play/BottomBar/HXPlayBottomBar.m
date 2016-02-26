//
//  HXPlayBottomBar.m
//  mia
//
//  Created by miaios on 16/2/25.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXPlayBottomBar.h"
#import "HXXib.h"

@implementation HXPlayBottomBar

HXXibImplementation

#pragma mark - Load Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    ;
}

- (void)viewConfigure {
    _containerView.backgroundColor = [UIColor clearColor];
}

#pragma mark - Property
- (void)setPause:(BOOL)pause {
    _pause = pause;
    [_pauseButton setImage:[UIImage imageNamed:(pause ? @"P-PauseIcon" : @"P-PlayIcon")] forState:UIControlStateNormal];
}

- (void)setEnablePrevious:(BOOL)enablePrevious {
    _enablePrevious = enablePrevious;
    _previousButton.enabled = enablePrevious;
}

- (void)setEnableNext:(BOOL)enableNext {
    _enableNext = enableNext;
    _nextButton.enabled = enableNext;
}

#pragma mark - Event Response
- (IBAction)favoriteButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(bottomBar:takeAction:)]) {
        [_delegate bottomBar:self takeAction:HXPlayBottomBarActionFavorite];
    }
}

- (IBAction)previousButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(bottomBar:takeAction:)]) {
        [_delegate bottomBar:self takeAction:HXPlayBottomBarActionPrevious];
    }
}

- (IBAction)pauseButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(bottomBar:takeAction:)]) {
        [_delegate bottomBar:self takeAction:HXPlayBottomBarActionPause];
    }
}

- (IBAction)nextButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(bottomBar:takeAction:)]) {
        [_delegate bottomBar:self takeAction:HXPlayBottomBarActionNext];
    }
}

- (IBAction)infectButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(bottomBar:takeAction:)]) {
        [_delegate bottomBar:self takeAction:HXPlayBottomBarActionInfect];
    }
}

@end
