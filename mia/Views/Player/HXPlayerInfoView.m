//
//  HXPlayerInfoView.m
//  mia
//
//  Created by miaios on 15/11/30.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXPlayerInfoView.h"
#import "HXXib.h"

@implementation HXPlayerInfoView

HXXibImplementation

#pragma mark - Event Response
- (IBAction)shareButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(playerInfoViewShouldShare:)]) {
        [_delegate playerInfoViewShouldShare:self];
    }
}

@end
