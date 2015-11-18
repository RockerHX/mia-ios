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
#import "SongListPlayer.h"
#import "MusicMgr.h"
#import "HXVersion.h"

@interface HXMusicDetailCoverCell () <SongListPlayerDataSource, SongListPlayerDelegate>
@end

@implementation HXMusicDetailCoverCell {
    SongListPlayer	*_songListPlayer;
    ShareItem *_playItem;
}

#pragma mark - Init Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initConfig];
    [self viewConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
    [self initData];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playButtonPressed)];
    [_coverView addGestureRecognizer:tap];
}

- (void)viewConfig {
    [self configFrontCover];
}

- (void)configFrontCover {
    _coverImageView.layer.borderColor = UIColorFromHex(@"d7dede", 1.0f).CGColor;
    _coverImageView.layer.borderWidth = 0.5f;
}

- (void)initData {
    _songListPlayer = [[SongListPlayer alloc] initWithModelID:(long)(__bridge void *)self name:@"DetailHeaderView Song List"];
    _songListPlayer.dataSource = self;
    _songListPlayer.delegate = self;
}

- (void)dealloc {
    _songListPlayer.dataSource = nil;
    _songListPlayer.delegate = nil;
}

#pragma mark - Event Response
- (IBAction)playButtonPressed {
    if ([[MusicMgr standard] isPlayingWithUrl:_playItem.music.murl]) {
        [[MusicMgr standard] pause];
        _playButton.selected = NO;
    } else {
        [self playMusic];
    }
}

#pragma mark - Public Methods
- (void)displayWithViewModel:(HXMusicDetailViewModel *)viewModel {
    _playItem = viewModel.playItem;
    [_coverImageView sd_setImageWithURL:viewModel.frontCoverURL];
    [self updatePlayState];
}

- (void)stopPlay {
    [self stopMusic];
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

#pragma mark - audio operations
- (void)playMusic {
    MusicItem *musicItem = [_playItem.music copy];
    if (!musicItem.murl || !musicItem.name || !musicItem.singerName) {
        NSLog(@"Music is nil, stop play it.");
        return;
    }
    
    [[MusicMgr standard] setCurrentPlayer:_songListPlayer];
    [_songListPlayer playWithMusicItem:_playItem.music];
    _playButton.selected = YES;
}

- (void)pauseMusic {
    [_songListPlayer pause];
    _playButton.selected = NO;
}

- (void)stopMusic {
    [_songListPlayer stop];
    _playButton.selected = NO;
}

#pragma mark - SongListPlayerDataSource
- (NSInteger)songListPlayerCurrentItemIndex {
    // 只有一首歌
    return 0;
}

- (NSInteger)songListPlayerNextItemIndex {
    return 0;
}

- (MusicItem *)songListPlayerItemAtIndex:(NSInteger)index {
    // 只有一首歌
    return _playItem.music;
}

#pragma mark - SongListPlayerDelegate
- (void)songListPlayerDidPlay {
    _playButton.selected = YES;
}

- (void)songListPlayerDidPause {
    _playButton.selected = NO;
}

- (void)songListPlayerDidCompletion {
    _playButton.selected = NO;
}

@end
