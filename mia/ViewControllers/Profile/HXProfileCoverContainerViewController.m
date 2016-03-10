//
//  HXProfileCoverContainerViewController.m
//  mia
//
//  Created by miaios on 16/1/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXProfileCoverContainerViewController.h"
#import "UIImageView+WebCache.h"
#import "FXBlurView.h"

@interface HXProfileCoverContainerViewController ()
@end

@implementation HXProfileCoverContainerViewController

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

+ (NSString *)segueIdentifier {
    return @"HXProfileCoverContainerIdentifier";
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    ;
}

- (void)viewConfigure {
    ;
}

#pragma mark - Property
- (void)setImageURL:(NSString *)imageURL {
    _imageURL = imageURL;
    
    __weak __typeof__(self)weakSelf = self;
    [_avatarBG sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf showImageAnimationOnImageView:strongSelf.avatarBG image:image];
    }];
}

#pragma mark - Private Methods
- (void)showImageAnimationOnImageView:(UIImageView *)imageView image:(UIImage *)image {
    [UIView transitionWithView:imageView
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        imageView.image = [self blurredImage:image];
                    } completion:nil];
}

- (UIImage *)blurredImage:(UIImage *)image {
    return [image blurredImageWithRadius:5.0f iterations:3 tintColor:[UIColor whiteColor]];
}

@end
