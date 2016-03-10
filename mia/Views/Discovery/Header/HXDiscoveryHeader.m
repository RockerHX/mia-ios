//
//  HXDiscoveryHeader.m
//  mia
//
//  Created by miaios on 16/2/22.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXDiscoveryHeader.h"
#import "HXXib.h"


@interface HXDiscoveryHeader () <
HXMusicStateViewDelegate
>
@end


@implementation HXDiscoveryHeader

HXXibImplementation

#pragma mark - Event Response
- (IBAction)shareButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(discoveryHeader:takeAction:)]) {
        [_delegate discoveryHeader:self takeAction:HXDiscoveryHeaderActionShare];
    }
}

#pragma mark - HXMusicStateViewDelegate Methods
- (void)musicStateViewTaped:(HXMusicStateView *)stateView {
    if (_delegate && [_delegate respondsToSelector:@selector(discoveryHeader:takeAction:)]) {
        [_delegate discoveryHeader:self takeAction:HXDiscoveryHeaderActionMusic];
    }
}

@end
