//
//  HXMusicDetailView.m
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXMusicDetailView.h"
#import "TTTAttributedLabel.h"
#import "HXInfectUserView.h"
#import "ShareItem.h"
#import "UIImageView+WebCache.h"
#import "MusicMgr.h"
#import "SongListPlayer.h"

@interface HXMusicDetailView () <SongListPlayerDataSource, SongListPlayerDelegate>
@end

@implementation HXMusicDetailView {
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
}

- (void)viewConfig {
    
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

- (IBAction)starButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(detailViewUserWouldStar:)]) {
        [_delegate detailViewUserWouldStar:self];
    }
}

#pragma mark - Public Methods
- (void)refreshWithItem:(ShareItem *)item {
    _playItem = item;
    
    [_coverImageView sd_setImageWithURL:[NSURL URLWithString:item.music.purl]];
    [self updatePlayButtonState];
    [self updateSongInfoLabel];
    [self updateStarButtonState];
    [self updateShareInfoLabel];
    [self updateInfectPromptLabel];
    [self updateLabel];
}

- (void)updateStarState:(BOOL)star {
    _playItem.favorite = star;
    [self updateStarButtonState];
}

#pragma mark - Private Methods
- (void)updatePlayButtonState {
    if (!_playItem) {
        return;
    }
    
    if ([[MusicMgr standard] isPlayingWithUrl:_playItem.music.murl]) {
        _playButton.selected = YES;
    } else {
        _playButton.selected = NO;
    }
}

- (void)updateSongInfoLabel {
//    _songInfoLabel.text;
}

- (void)updateStarButtonState {
    [_starButton setImage:[UIImage imageNamed:_playItem.favorite ? @"MD-StarIcon" : @"MD-UnStarIcon"] forState:UIControlStateNormal];
}

- (void)updateShareInfoLabel {
//    _songInfoLabel.text;
}

- (void)updateInfectPromptLabel {
//    _infectPromptLabel.text;
}

- (void)updateLabel {
    _viewCountLabel.text = @(_playItem.cView).stringValue;
    _locationLabel.text = _playItem.sAddress;
    _commentCountLabel.text = @(_playItem.cComm).stringValue;
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
