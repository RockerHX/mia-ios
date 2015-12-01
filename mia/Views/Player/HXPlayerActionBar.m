//
//  HXPlayerActionBar.m
//  mia
//
//  Created by miaios on 15/11/30.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXPlayerActionBar.h"
#import "HXXib.h"

@implementation HXPlayerActionBar

HXXibImplementation

#pragma mark -
- (IBAction)previousButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(actionBar:action:)]) {
        [_delegate actionBar:self action:HXPlayerActionBarActionPrevious];
    }
}

- (IBAction)playButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(actionBar:action:)]) {
        [_delegate actionBar:self action:HXPlayerActionBarActionPlay];
    }
}

- (IBAction)nextButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(actionBar:action:)]) {
        [_delegate actionBar:self action:HXPlayerActionBarActionNext];
    }
}

@end
