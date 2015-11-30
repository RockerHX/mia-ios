//
//  HXFavoriteHeader.m
//  mia
//
//  Created by miaios on 15/11/27.
//  Copyright © 2015年 miaios. All rights reserved.
//

#import "HXFavoriteHeader.h"
#import "HXXib.h"

@implementation HXFavoriteHeader

HXXibImplementation

#pragma Event Response
- (IBAction)playButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(favoriteHeader:takeAction:)]) {
        [_delegate favoriteHeader:self takeAction:HXFavoriteHeaderActionPlay];
    }
}

- (IBAction)editButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(favoriteHeader:takeAction:)]) {
        [_delegate favoriteHeader:self takeAction:HXFavoriteHeaderActionEdit];
    }
}

@end
