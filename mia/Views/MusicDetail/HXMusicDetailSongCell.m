//
//  HXMusicDetailSongCell.m
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXMusicDetailSongCell.h"
#import "TTTAttributedLabel.h"
#import "ShareItem.h"
#import "MusicItem.h"

@implementation HXMusicDetailSongCell

#pragma mark - Init Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
    _songInfoLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 120.0f;
}

#pragma mark - Event Response
- (IBAction)starButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(cellUserWouldLikeStar:)]) {
        [_delegate cellUserWouldLikeStar:self];
    }
}

#pragma mark - Public Methods
- (void)displayWithPlayItem:(ShareItem *)item {
    MusicItem *musicItem = item.music;
    [self displaySongInfoLabelWithSongName:musicItem.name singerName:[@"  " stringByAppendingString:musicItem.singerName]];
    [self updateStatStateWithFavorite:item.favorite];
}

- (void)updateStatStateWithFavorite:(BOOL)favorite {
    if (favorite) {
        [_starButton setImage:[UIImage imageNamed:@"MD-StarIcon"] forState:UIControlStateNormal];
    } else {
        [_starButton setImage:[UIImage imageNamed:@"MD-UnStarIcon"] forState:UIControlStateNormal];
    }
}

#pragma mark - Private Methods
- (void)displaySongInfoLabelWithSongName:(NSString *)songerName singerName:(NSString *)singerName {
    NSString *text = [NSString stringWithFormat:@"%@%@", (songerName.length ? songerName : @""), (singerName ?: @"")];
    
    [_songInfoLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange boldRange = [[mutableAttributedString string] rangeOfString:singerName options:NSCaseInsensitiveSearch];
        [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)[UIColor lightGrayColor].CGColor range:boldRange];
        return mutableAttributedString;
    }];
}

@end
