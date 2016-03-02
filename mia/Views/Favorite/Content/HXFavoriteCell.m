//
//  HXFavoriteCell.m
//  mia
//
//  Created by miaios on 16/2/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXFavoriteCell.h"
#import "UIConstants.h"
#import "FavoriteItem.h"

@implementation HXFavoriteCell

#pragma mark - Public Methods
- (void)displayWithFavoriteList:(NSArray *)list index:(NSInteger)index selected:(BOOL)selected {
    if (index < list.count) {
        FavoriteItem *favorite = list[index];
        _indexLabel.text = @(index + 1).stringValue;
        _songNameLabel.text = favorite.music.name;
        _singerNameLabel.text = favorite.music.singerName;
    }
    
    UIColor *color = selected ? UIColorByHex(0x04B4A2) : [UIColor blackColor];
    
    _indexLabel.textColor = color;
    _songNameLabel.textColor = color;
    _singerNameLabel.textColor = color;
}

@end
