//
//  HXPlayerTopBar.m
//  mia
//
//  Created by miaios on 15/11/30.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXPlayerTopBar.h"
#import "HXXib.h"

@implementation HXPlayerTopBar

HXXibImplementation

#pragma mark - Event Response
- (IBAction)backButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(topBar:action:)]) {
        [_delegate topBar:self action:HXPlayerTopBarActionBack];
    }
}

- (IBAction)listButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(topBar:action:)]) {
        [_delegate topBar:self action:HXPlayerTopBarActionList];
    }
}

@end
