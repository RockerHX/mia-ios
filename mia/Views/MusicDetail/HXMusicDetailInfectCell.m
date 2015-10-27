//
//  HXMusicDetailInfectCell.m
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXMusicDetailInfectCell.h"
#import "HXMusicDetailViewModel.h"
#import "TTTAttributedLabel.h"
#import "HXInfectUserView.h"

@implementation HXMusicDetailInfectCell

#pragma mark - Init Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(infectUsersTaped)];
    [_infectPromptLabel addGestureRecognizer:tapGesture];
}

#pragma mark - Public Methods
- (void)displayWithViewModel:(HXMusicDetailViewModel *)viewModel {
    ShareItem *item = viewModel.playItem;
    _infectPromptLabel.text = [NSString stringWithFormat:@"%@人妙推", @(item.infectTotal)];
}

#pragma mark - Event Response
- (void)infectUsersTaped {
    if (_delegate && [_delegate respondsToSelector:@selector(cellUserWouldLikeShowInfectList:)]) {
        [_delegate cellUserWouldLikeShowInfectList:self];
    }
}

@end
