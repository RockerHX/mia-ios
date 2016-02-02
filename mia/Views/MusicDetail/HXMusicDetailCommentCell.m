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

#pragma mark - Awake Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Config Methods
- (void)loadConfigure {
    _contentLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 70.0f;
    
    [_avatar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTaped)]];
}

- (void)viewConfigure {
    ;
}

#pragma mark - Event Response
- (void)avatarTaped {
    if (_delegate && [_delegate respondsToSelector:@selector(commentCellAvatarTaped:)]) {
        [_delegate commentCellAvatarTaped:self];
    }
}

#pragma mark - Public Methods
- (void)displayWithComment:(HXComment *)comment {
    [_avatar sd_setImageWithURL:[NSURL URLWithString:comment.headerURL] placeholderImage:[UIImage imageNamed:@"HP-ProfileIcon"]];
    _nameLabel.text = comment.nickName;
    _contentLabel.text = comment.content;
}

@end
