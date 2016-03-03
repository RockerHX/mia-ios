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
#import "UIConstants.h"
#import "MusicMgr.h"

@implementation HXMusicDetailCoverCell {
    ShareItem *_playItem;
}

#pragma mark - Init Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Config Methods
- (void)loadConfigure {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playButtonPressed)];
    [_coverView addGestureRecognizer:tap];
}

- (void)viewConfigure {
    _coverImageView.layer.borderColor = UIColorByHex(0xd7dede).CGColor;
    _coverImageView.layer.borderWidth = 0.5f;
}

#pragma mark - Event Response
- (IBAction)playButtonPressed {
    HXMusicDetailCoverCellAction action = HXMusicDetailCoverCellActionPlay;
    MusicMgr *musicMgr = [MusicMgr standard];
    if ([musicMgr isPlayingWithUrl:_playItem.music.murl]) {
        action = HXMusicDetailCoverCellActionPause;
        _playButton.selected = NO;
    } else {
        _playButton.selected = YES;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(coverCell:takeAction:)]) {
        [_delegate coverCell:self takeAction:action];
    }
}

#pragma mark - Public Methods
- (void)displayWithViewModel:(HXMusicDetailViewModel *)viewModel {
    _playItem = viewModel.playItem;
    [_coverImageView sd_setImageWithURL:[NSURL URLWithString:viewModel.playItem.music.purl]];
    [self updatePlayState];
}

#pragma mark - Private Methods
- (void)updatePlayState {
    if (!_playItem) {
        return;
    }
    
    if ([[MusicMgr standard] isPlayingWithUrl:_playItem.music.murl]) {
        _playButton.selected = YES;
    } else {
        _playButton.selected = NO;
    }
}

@end
