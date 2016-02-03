//
//  HXProfileShareCell.m
//  mia
//
//  Created by miaios on 16/1/29.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXProfileShareCell.h"
#import "UIImageView+WebCache.h"

@implementation HXProfileShareCell

#pragma mark - Load Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    _titleLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 36.0f;
}

- (void)viewConfigure {
    ;
}

#pragma mark - Setter And Getter
- (void)setFavorite:(BOOL)favorite {
    _favorite = favorite;
    
    [_favoriteButton setImage:[UIImage imageNamed:(favorite ? @"P-FavoritedIcon" : @"P-UnFavoriteIcon")] forState:UIControlStateNormal];
}

#pragma mark - Event Response
- (IBAction)playButtonPressed {
    ;
}

- (IBAction)favoriteButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(shareCell:takeAction:)]) {
        [_delegate shareCell:self takeAction:HXProfileShareCellActionFavorite];
    }
}

- (IBAction)deleteButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(shareCell:takeAction:)]) {
        [_delegate shareCell:self takeAction:HXProfileShareCellActionDelete];
    }
}

#pragma mark - Public Methods
- (void)displayWithItem:(ShareItem *)item {
    self.favorite = item.favorite;
    [_cover sd_setImageWithURL:[NSURL URLWithString:item.music.purl] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    
    _descriptionLabel.text = [item.formatTime stringByAppendingFormat:@" 分享了"];
    _songLabel.text = item.music.name;
    _singerLabel.text = item.music.singerName;
    _commentCountLabel.text = @(item.cComm).stringValue;
    _seeCountLabel.text = @(item.cView).stringValue;
    
    [self displayTitle:item.sNote];
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

@end
