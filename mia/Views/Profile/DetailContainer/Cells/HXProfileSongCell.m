//
//  HXProfileSongCell.m
//  mia
//
//  Created by miaios on 16/1/29.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXProfileSongCell.h"

@implementation HXProfileSongCell

#pragma mark - Public Methods
- (void)displayWithItem:(FavoriteItem *)item index:(NSInteger)index {
    MusicItem *musicItem = item.music;
    
    _indexLabel.text = @(index).stringValue;
    _promptLabel.text = [NSString stringWithFormat:@"由%@分享", item.sNick];
    _downLoadIcon.image = [UIImage imageNamed:(item.isCached ? @"PF-DownLoadedIcon" : @"PF-DownLoadIcon")];
    _songInfoLabel.text = [musicItem.name stringByAppendingFormat:@"-%@", musicItem.singerName];
}

@end
