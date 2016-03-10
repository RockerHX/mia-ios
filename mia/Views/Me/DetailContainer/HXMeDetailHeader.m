//
//  HXMeDetailHeader.m
//  mia
//
//  Created by miaios on 16/1/28.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXMeDetailHeader.h"
#import "HXXib.h"
#import "UIImageView+WebCache.h"
#import "HXVersion.h"


@implementation HXMeDetailHeader {
    NSString *_placeHolderImageURL;
    UIImage *_placeHolderImage;
}

HXXibImplementation

#pragma mark - Load Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    _placeHolderImage = [UIImage imageNamed:@"C-AvatarDefaultIcon"];
}

- (void)viewConfigure {
    _containerView.backgroundColor = [UIColor clearColor];
    
    if ([HXVersion currentModel] == SCDeviceModelTypeIphone5_5S) {
        _avatar.layer.cornerRadius = 38.0f;
        _avatarWidthConstraint.constant = 76.0f;
    }
}

#pragma mark - Event Response
- (IBAction)settingButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(detailHeader:takeAction:)]) {
        [_delegate detailHeader:self takeAction:HXMeDetailHeaderActionSetting];
    }
}

- (IBAction)playViewTaped {
    if (_delegate && [_delegate respondsToSelector:@selector(detailHeader:takeAction:)]) {
        [_delegate detailHeader:self takeAction:HXMeDetailHeaderActionPlay];
    }
}

- (IBAction)fansViewTaped {
    if (_delegate && [_delegate respondsToSelector:@selector(detailHeader:takeAction:)]) {
        [_delegate detailHeader:self takeAction:HXMeDetailHeaderActionShowFans];
    }
}

- (IBAction)followViewTaped {
    if (_delegate && [_delegate respondsToSelector:@selector(detailHeader:takeAction:)]) {
        [_delegate detailHeader:self takeAction:HXMeDetailHeaderActionShowFollow];
    }
}

#pragma mark - Public Methods
- (void)displayWithHeaderModel:(HXProfileHeaderModel *)model {
    _nickNameLabel.text = model.nickName;
    _playNickNameLabel.text = model.nickName;
    _fansCountLabel.text = model.fansCount;
    _followCountLabel.text = model.followCount;
    
    if ([model.avatar isEqualToString:_placeHolderImageURL]) {
        return;
    }
    
    _placeHolderImageURL = model.avatar;
    __weak __typeof__(self)weakSelf = self;
    [_avatar sd_setImageWithURL:[NSURL URLWithString:_placeHolderImageURL] placeholderImage:_placeHolderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf->_placeHolderImage = image;
        [strongSelf showImageAnimationOnImageView:strongSelf.avatar image:image];
    }];
}

#pragma mark - Private Methods
- (void)showImageAnimationOnImageView:(UIImageView *)imageView image:(UIImage *)image {
    image = image ?: [UIImage imageNamed:@"C-AvatarDefaultIcon"];
    [UIView transitionWithView:imageView
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        imageView.image = image;
                    } completion:nil];
}

#pragma mark - HXMessagePromptViewDelegate Methods
- (void)messagePromptViewTaped:(HXMessagePromptView *)view {
    if (_delegate && [_delegate respondsToSelector:@selector(detailHeader:takeAction:)]) {
        [_delegate detailHeader:self takeAction:HXMeDetailHeaderActionShowMessage];
    }
}

@end
