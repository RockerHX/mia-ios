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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MusicMgrNotificationPlayerEvent object:nil];
}

#pragma mark - Config Methods
- (void)loadConfigure {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationPlayerEvent:) name:MusicMgrNotificationPlayerEvent object:nil];
}

- (void)viewConfigure {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playButtonPressed)];
    [_coverView addGestureRecognizer:tap];
    
    _coverImageView.layer.borderColor = UIColorByHex(0xd7dede).CGColor;
    _coverImageView.layer.borderWidth = 0.5f;
}

#pragma mark - Event Response
- (IBAction)playButtonPressed {
    MusicMgr *musicMgr = [MusicMgr standard];
    if ([musicMgr.currentItem.music.murl isEqualToString:_playItem.music.murl]) {
        if (musicMgr.isPlaying) {
            _playButton.selected = NO;
            [musicMgr pause];
        } else {
            _playButton.selected = YES;
            [[MusicMgr standard] playCurrent];
        }
    } else {
        _playButton.selected = YES;
        if (_delegate && [_delegate respondsToSelector:@selector(coverCell:takeAction:)]) {
            [_delegate coverCell:self takeAction:HXMusicDetailCoverCellActionPlay];
        }
    }
}

#pragma mark - Notification Methods
- (void)notificationPlayerEvent:(NSNotification *)notification {
    NSString *sID = notification.userInfo[MusicMgrNotificationKey_sID];
    MiaPlayerEvent event = [notification.userInfo[MusicMgrNotificationKey_PlayerEvent] unsignedIntegerValue];
    
    if ([_playItem.sID isEqualToString:sID]) {
        switch (event) {
            case MiaPlayerEventDidPlay:
                _playButton.selected = YES;
                break;
            case MiaPlayerEventDidPause:
            case MiaPlayerEventDidCompletion:
                _playButton.selected = NO;
                break;
            default:
                NSLog(@"It's a bug, sID: %@, PlayerEvent: %lu", sID, (unsigned long)event);
                break;
        }
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
