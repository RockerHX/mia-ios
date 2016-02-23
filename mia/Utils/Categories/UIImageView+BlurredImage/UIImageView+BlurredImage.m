//
//  UIImageView+BlurredImage.m
//
//  Created by linyehui on 14-9-24.
//
//

#import "UIImageView+BlurredImage.h"
#import "UIImage+ImageEffects.h"

CGFloat const BBlurredImageDefaultBlurRadius            = 20.0;
CGFloat const BBlurredImageDefaultSaturationDeltaFactor = 1.8;

@implementation UIImageView (BlurredImage)

/**
 *  修改图像为毛玻璃效果
 *
 *  @param image      原始图像
 *  @param blurRadius 模糊度数
 *  @param completion 回调
 */
- (void)setImageToBlur:(UIImage *)image blurRadius:(CGFloat)blurRadius completionBlock:(BlurredImageCompletionBlock)completion{
    NSParameterAssert(image);
    NSParameterAssert(blurRadius >= 0);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIImage *blurredImage = [image applyBlurWithRadius:blurRadius tintColor:nil saturationDeltaFactor:BBlurredImageDefaultSaturationDeltaFactor maskImage:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image = blurredImage;
            if (completion) {
                completion();
            }
        });
    });
}

@end
