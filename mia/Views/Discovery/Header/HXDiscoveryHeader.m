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
- (IBAction)profileButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(discoveryActionHeader:takeAction:)]) {
        [_delegate discoveryActionHeader:self takeAction:HXDiscoveryHeaderActionProfile];
    }
}

- (IBAction)shareButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(discoveryActionHeader:takeAction:)]) {
        [_delegate discoveryActionHeader:self takeAction:HXDiscoveryHeaderActionShare];
    }
}

@end
