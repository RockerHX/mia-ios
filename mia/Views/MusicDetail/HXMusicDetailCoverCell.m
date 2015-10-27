//
//  HXMusicDetailCoverCell.m
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXMusicDetailCoverCell.h"
#import "HXMusicDetailViewModel.h"
#import "UIImageView+WebCache.h"

@implementation HXMusicDetailCoverCell

#pragma mark - Event Response
- (IBAction)playButtonPressed {
//    if ([[MusicMgr standard] isPlayingWithUrl:_playItem.music.murl]) {
//        [[MusicMgr standard] pause];
//        _playButton.selected = NO;
//    } else {
//        [self playMusic];
//    }
}

#pragma mark - Public Methods
- (void)displayWithViewModel:(HXMusicDetailViewModel *)viewModel {
    [_coverImageView sd_setImageWithURL:viewModel.frontCoverURL];
}

@end
