//
//  HXSegmentItemView.m
//  Mia
//
//  Created by miaios on 15/12/8.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXSegmentItemView.h"

@implementation HXSegmentItemView

#pragma mark - Setter And Getter
- (void)setSelected:(BOOL)selected {
    _selected = selected;
    _titleLabel.textColor = selected ? UIColorFromHex(@"0CB4A3", 1.0f) : UIColorFromHex(@"808080", 1.0f);
    _countLabel.textColor = _titleLabel.textColor;
}

#pragma mark - Event Response
- (IBAction)buttonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(itemViewSelected:)]) {
        [_delegate itemViewSelected:self];
    }
}

@end
