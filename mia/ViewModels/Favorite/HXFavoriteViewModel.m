//
//  HXFavoriteViewModel.m
//  mia
//
//  Created by miaios on 15/11/30.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXFavoriteViewModel.h"

@implementation HXFavoriteViewModel

MJCodingImplementation

#pragma mark - Init Methods
- (instancetype)initWithFavoriteItem:(FavoriteItem *)item {
    self = [super init];
    if (self) {
        _item = item;
    }
    return self;
}

@end
