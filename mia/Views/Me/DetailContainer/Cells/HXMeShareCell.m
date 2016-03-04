//
//  HXMeShareCell.m
//  mia
//
//  Created by miaios on 16/1/29.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXMeShareCell.h"
#import "UIImageView+WebCache.h"
#import "UIConstants.h"
#import "MusicMgr.h"

@implementation HXMeShareCell {
    __weak ShareItem *_shareItem;
}

#pragma mark - Load Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    _titleLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 36.0f;
    _songLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 151.0f;
}

- (void)viewConfigure {
    ;
}

#pragma mark - Setter And Getter
- (void)setFavorite:(BOOL)favorite {
    _favorite = favorite;
    
    [_favoriteButton setImage:[UIImage imageNamed:(favorite ? @"PF-FavoritedIcon" : @"PF-FavoriteIcon")] forState:UIControlStateNormal];
}

#pragma mark - Event Response
- (IBAction)playButtonPressed {
    MusicMgr *musicMgr = [MusicMgr standard];
    if ([musicMgr.currentItem.music.murl isEqualToString:_shareItem.music.murl]) {
        if (musicMgr.isPlaying) {
            _playButton.selected = NO;
            [musicMgr pause];
        } else {
            _playButton.selected = YES;
            [[MusicMgr standard] playCurrent];
        }
    } else {
        _playButton.selected = YES;
        if (_delegate && [_delegate respondsToSelector:@selector(shareCell:takeAction:)]) {
            [_delegate shareCell:self takeAction:HXMeShareCellActionPlay];
        }
    }
}

- (IBAction)favoriteButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(shareCell:takeAction:)]) {
        [_delegate shareCell:self takeAction:HXMeShareCellActionFavorite];
    }
}

- (IBAction)deleteButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(shareCell:takeAction:)]) {
        [_delegate shareCell:self takeAction:HXMeShareCellActionDelete];
    }
}

#pragma mark - Public Methods
- (void)displayWithItem:(ShareItem *)item {
    _shareItem = item;
    
    self.favorite = item.favorite;
    [_cover sd_setImageWithURL:[NSURL URLWithString:item.music.purl]];
    
    _descriptionLabel.text = item.formatTime;
    _songLabel.text = item.music.name;
    _singerLabel.text = item.music.singerName;
    _commentCountLabel.text = @(item.cComm).stringValue;
    
    [self displayTitle:item.sNote];
    [self updatePlayState];
}

#pragma mark - Private Methods
- (void)displayTitle:(NSString *)title {
    _titleLabel.text = title;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:_titleLabel.attributedText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:4.0f];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [title length])];
    _titleLabel.attributedText = attributedString;
}

- (void)updatePlayState {
    MusicMgr *musicMgr = [MusicMgr standard];
    if ([musicMgr isPlayingWithUrl:_shareItem.music.murl]) {
        _playButton.selected = YES;
    } else {
        _playButton.selected = NO;
    }
}

@end
