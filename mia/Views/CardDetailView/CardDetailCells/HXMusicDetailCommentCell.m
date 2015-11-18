//
//  HXMusicDetailCommentCell.m
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXMusicDetailCommentCell.h"
#import "UIImageView+WebCache.h"

@implementation HXMusicDetailCommentCell

#pragma mark - Init Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initConfig];
    [self viewConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
    _contentLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 70.0f;
}

- (void)viewConfig {
}

#pragma mark - Public Methods
- (void)displayWithComment:(nullable HXComment *)comment {
    _contentLabel.text = comment.content;
}

@end
