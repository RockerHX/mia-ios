//
//  HXInfectCell.m
//  mia
//
//  Created by miaios on 16/2/25.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXInfectCell.h"
#import "UIImageView+WebCache.h"

@implementation HXInfectCell

#pragma mark - Class Methods
+ (UINib *)nib {
    return [UINib nibWithNibName:NSStringFromClass([HXInfectCell class]) bundle:nil];
}

+ (NSString *)className {
    return NSStringFromClass([HXInfectCell class]);
}

#pragma mark - Load Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    _avatar.layer.drawsAsynchronously = YES;
}

- (void)viewConfigure {
    ;
}

#pragma mark - Public Methods
- (void)displayWithInfecter:(InfectUserItem *)infecter {
    _avatar.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    __weak __typeof__(self)weakSelf = self;
    [_avatar sd_setImageWithURL:[NSURL URLWithString:infecter.avatar] placeholderImage:[UIImage imageNamed:@"C-AvatarDefaultIcon"] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        __strong __typeof__(self)strongSelf = weakSelf;
        [self showImageAnimationOnImageView:strongSelf.avatar image:image];
    }];
}

#pragma mark - Private Methods
- (void)showImageAnimationOnImageView:(UIImageView *)imageView image:(UIImage *)image {
    [UIView animateWithDuration:0.3f delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        _avatar.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3f delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            _avatar.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.4f delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                _avatar.transform = CGAffineTransformIdentity;
            } completion:nil];
        }];
    }];
}

@end
