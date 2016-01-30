//
//  HXProfileSongActionCell.m
//  mia
//
//  Created by miaios on 16/1/29.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXProfileSongActionCell.h"

@implementation HXProfileSongActionCell

#pragma mark - Event Response
- (IBAction)playButtonPressed:(UIButton *)button {
    button.selected = !button.selected;
    
    if (_delegate && [_delegate respondsToSelector:@selector(songActionCell:takeAction:)]) {
        [_delegate songActionCell:self takeAction:button.selected ? HXProfileSongActionPlay : HXProfileSongActionPause];
    }
}

- (IBAction)editButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(songActionCell:takeAction:)]) {
        [_delegate songActionCell:self takeAction:HXProfileSongActionEdit];
    }
}

@end
