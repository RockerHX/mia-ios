//
//  HXMusicDetailSongCell.m
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXMusicDetailSongCell.h"
#import "TTTAttributedLabel.h"
#import "MusicItem.h"

@implementation HXMusicDetailSongCell

#pragma mark - Init Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
    _songInfoLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 74.0f;
}

#pragma mark - Event Response
- (IBAction)starButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(cellUserWouldLikeStar:)]) {
        [_delegate cellUserWouldLikeStar:self];
    }
}

#pragma mark - Public Methods
- (void)displayWithMusicItem:(MusicItem *)item {
    _songInfoLabel.text = [NSString stringWithFormat:@"%@  %@", item.name, item.singerName];
}

- (void)updateStatStateWithFavorite:(BOOL)favorite {
    if (favorite) {
        [_starButton setImage:[UIImage imageNamed:@"MD-StarIcon"] forState:UIControlStateNormal];
    } else {
        [_starButton setImage:[UIImage imageNamed:@"MD-UnStarIcon"] forState:UIControlStateNormal];
    }
}

@end
