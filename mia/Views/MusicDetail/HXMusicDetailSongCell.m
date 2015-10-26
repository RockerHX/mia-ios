//
//  HXMusicDetailSongCell.m
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXMusicDetailSongCell.h"
#import "TTTAttributedLabel.h"

@implementation HXMusicDetailSongCell

#pragma mark - Event Response
- (IBAction)starButtonPressed {
//    if (_delegate && [_delegate respondsToSelector:@selector(detailViewUserWouldStar:)]) {
//        [_delegate detailViewUserWouldStar:self];
//    }
}

#pragma mark - Public Methods
- (void)displayWithViewModel:(HXMusicDetailViewModel *)viewModel {
    _songInfoLabel.text = @"WWW";
}

@end
