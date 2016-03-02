//
//  HXFavoriteEditCell.m
//  mia
//
//  Created by miaios on 16/3/2.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXFavoriteEditCell.h"
#import "FavoriteItem.h"

@implementation HXFavoriteEditCell

#pragma mark - Public Methods
- (void)displayWithItem:(FavoriteItem *)item {
    _stateIcon.image = [UIImage imageNamed:(item.isSelected ? @"F-SelectedIcon" : @"F-SelecteIcon")];
    _songNameLabel.text = item.music.name;
    _singerNameLabel.text = item.music.singerName;
}

@end
