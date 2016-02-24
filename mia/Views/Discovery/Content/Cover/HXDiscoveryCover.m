//
//  HXDiscoveryCover.m
//  mia
//
//  Created by miaios on 16/2/22.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXDiscoveryCover.h"
#import "HXXib.h"
#import "MusicItem.h"
#import "UIImageView+WebCache.h"

@implementation HXDiscoveryCover

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
    ;
}

#pragma mark - Public Methods
- (void)displayWithMusicItem:(MusicItem *)item {
    __weak __typeof__(self)weakSelf = self;
    [_cover sd_setImageWithURL:[NSURL URLWithString:item.purl] placeholderImage:nil options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        __strong __typeof__(self)strongSelf = weakSelf;
        [UIView transitionWithView:strongSelf.cover
                          duration:0.5f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            strongSelf.cover.image = image;
                        } completion:nil];
    }];
}

@end
