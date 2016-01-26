//
//  HXMessageCell.m
//  mia
//
//  Created by miaios on 16/1/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXMessageCell.h"

@implementation HXMessageCell

#pragma mark - Load Methods
- (void)awakeFromNib {
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    ;
}

- (void)viewConfigure {
    ;
}

#pragma mark - Event Response
- (IBAction)avatarButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(messageCell:takeAction:)]) {
        [_delegate messageCell:self takeAction:HXMessageCellActionAvatarTaped];
    }
}

#pragma mark - Public Methods
- (void)displayWithMessageModel:(HXMessageModel *)model {
    ;
}

@end
