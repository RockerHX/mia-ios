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

#pragma mark - Event Response
- (IBAction)playButtonPressed {
    
}

- (IBAction)favoriteButtonPressed {
    
}

- (IBAction)deleteButtonPressed {
    
}

#pragma mark - Public Methods
- (void)displayWithItem:(ShareItem *)item {
    [_cover sd_setImageWithURL:[NSURL URLWithString:item.music.purl] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    
    [_favoriteButton setImage:[UIImage imageNamed:(item.favorite ? @"P-FavoritedIcon" : @"P-UnFavoriteIcon")] forState:UIControlStateNormal];
    
    _titleLabel.text = item.sNote;
    _descriptionLabel.text = [item.formatTime stringByAppendingFormat:@" 分享了"];
    _songLabel.text = item.music.name;
    _singerLabel.text = item.music.singerName;
    _commentCountLabel.text = @(item.cComm).stringValue;
    _seeCountLabel.text = @(item.cView).stringValue;
}

@end
