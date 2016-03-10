//
//  HXProfileDetailHeader.m
//  mia
//
//  Created by miaios on 16/1/28.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXProfileDetailHeader.h"
#import "HXXib.h"
#import "UIImageView+WebCache.h"

@implementation HXProfileDetailHeader

HXXibImplementation

#pragma mark - Load Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    ;
}

- (void)viewConfigure {
    _containerView.backgroundColor = [UIColor clearColor];
}

#pragma mark - Property
- (void)setFollow:(BOOL)follow {
    _follow = follow;
    
    [_actionButton setImage:[UIImage imageNamed:(follow ? @"PF-AttentionedIcon" : @"PF-AttentionIcon")] forState:UIControlStateNormal];
}

- (void)setHost:(BOOL)host {
    _host = host;
    
    if (host) {
        _actionButton.hidden = YES;
        _actionButtonWidthConstraint.constant = 0.0f;
    }
}

#pragma mark - Event Response
- (IBAction)actionButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(detailHeader:takeAction:)]) {
        [_delegate detailHeader:self takeAction:HXProfileDetailHeaderActionAttention];
    }
}

- (IBAction)playViewTaped {
    if (_delegate && [_delegate respondsToSelector:@selector(detailHeader:takeAction:)]) {
        [_delegate detailHeader:self takeAction:HXProfileDetailHeaderActionPlay];
    }
}

- (IBAction)fansViewTaped {
    if (_delegate && [_delegate respondsToSelector:@selector(detailHeader:takeAction:)]) {
        [_delegate detailHeader:self takeAction:HXProfileDetailHeaderActionShowFans];
    }
}

- (IBAction)followViewTaped {
    if (_delegate && [_delegate respondsToSelector:@selector(detailHeader:takeAction:)]) {
        [_delegate detailHeader:self takeAction:HXProfileDetailHeaderActionShowFollow];
    }
}

#pragma mark - Public Methods
- (void)displayWithHeaderModel:(HXProfileHeaderModel *)model {
    __weak __typeof__(self)weakSelf = self;
    [_avatar sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:@"C-AvatarDefaultIcon"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf showImageAnimationOnImageView:strongSelf.avatar image:image];
    }];
    
    _nickNameLabel.text = model.nickName;
    _playNickNameLabel.text = model.nickName;
    _fansCountLabel.text = model.fansCount;
    _followCountLabel.text = model.followCount;
}

#pragma mark - Private Methods
- (void)showImageAnimationOnImageView:(UIImageView *)imageView image:(UIImage *)image {
    [UIView transitionWithView:imageView
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        imageView.image = image;
                    } completion:nil];
}

@end
