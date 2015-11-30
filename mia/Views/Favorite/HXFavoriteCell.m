//
//  HXFavoriteCell.m
//  mia
//
//  Created by miaios on 15/11/27.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXFavoriteCell.h"
#import "UIImageView+WebCache.h"

@implementation HXFavoriteCell

#pragma mark - Public Methods
- (void)displayWithItem:(FavoriteItem *)item {
    MusicItem *musicItem = item.music;
    [_frontCover sd_setImageWithURL:[NSURL URLWithString:musicItem.albumURL]];
    _downloadStateIcon.image = [UIImage imageNamed:(item.isCached ? @"F-DwonloadedIcon" : @"F-DwonloadIcon")];
    _songNameLabel.text = musicItem.name;
    _singerLabel.text = musicItem.singerName;
}

@end
