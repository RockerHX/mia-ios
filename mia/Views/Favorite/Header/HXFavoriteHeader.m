//
//  HXFavoriteHeader.m
//  mia
//
//  Created by miaios on 16/2/22.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXFavoriteHeader.h"
#import "HXXib.h"

@implementation HXFavoriteHeader

HXXibImplementation

#pragma mark - Event Response
- (IBAction)shufflePlayViewTaped {
    if (_delegate && [_delegate respondsToSelector:@selector(favoriteHeader:takeAction:)]) {
        [_delegate favoriteHeader:self takeAction:HXFavoriteHeaderActionShuffle];
    }
}

- (IBAction)multipleSelectedViewTaped {
    if (_delegate && [_delegate respondsToSelector:@selector(favoriteHeader:takeAction:)]) {
        [_delegate favoriteHeader:self takeAction:HXFavoriteHeaderActionEdit];
    }
}

@end
