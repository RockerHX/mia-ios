//
//  HXPlayListCell.m
//  mia
//
//  Created by miaios on 16/2/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXPlayListCell.h"
#import "MusicItem.h"
#import "UIConstants.h"

@implementation HXPlayListCell

#pragma mark - Public Methods
- (void)displayWithMusicList:(NSArray *)list index:(NSInteger)index selected:(BOOL)selected {
    if (index < list.count) {
        MusicItem *music = list[index];
        _indexLabel.text = @(index + 1).stringValue;
        _songNameLabel.text = music.name;
        _singerNameLabel.text = music.singerName;
    }
    
    UIColor *color = selected ? UIColorByHex(0x04B4A2) : [UIColor blackColor];
    
    _indexLabel.textColor = color;
    _songNameLabel.textColor = color;
    _singerNameLabel.textColor = selected ? UIColorByHex(0x04B4A2) : UIColorByHex(0x808080);
}

@end
