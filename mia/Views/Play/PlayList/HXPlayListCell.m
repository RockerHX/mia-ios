//
//  HXPlayListCell.m
//  mia
//
//  Created by miaios on 16/2/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXPlayListCell.h"
#import "MusicItem.h"

@implementation HXPlayListCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -
- (void)displayWithMusicList:(NSArray *)list index:(NSInteger)index {
    if (index < list.count) {
        MusicItem *music = list[index];
        _indexLabel.text = @(index).stringValue;
        _songNameLabel.text = music.name;
        _singerNameLabel.text = music.singerName;
    }
}

@end
