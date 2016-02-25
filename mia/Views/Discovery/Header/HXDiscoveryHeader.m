//
//  HXDiscoveryHeader.m
//  mia
//
//  Created by miaios on 16/2/22.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXDiscoveryHeader.h"
#import "HXXib.h"

@implementation HXDiscoveryHeader

HXXibImplementation

#pragma mark - Event Response
- (IBAction)shareButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(discoveryHeader:takeAction:)]) {
        [_delegate discoveryHeader:self takeAction:HXDiscoveryHeaderActionShare];
    }
}
- (IBAction)playButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(discoveryHeader:takeAction:)]) {
        [_delegate discoveryHeader:self takeAction:HXDiscoveryHeaderActionPlay];
    }
}

@end
