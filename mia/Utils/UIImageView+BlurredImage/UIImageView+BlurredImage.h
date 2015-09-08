//
//  UIImageView+BlurredImage.h
//
//  Created by linyehui on 14-9-24.
//
//

#import <UIKit/UIKit.h>

typedef void(^BlurredImageCompletionBlock)(void);

extern CGFloat const BlurredImageDefaultBlurRadius;

@interface UIImageView (BlurredImage)

/**
 *  修改图像为毛玻璃效果
 *
 *  @param image      原始图像
 *  @param blurRadius 模糊度数
 *  @param completion 回调
 */
- (void)setImageToBlur:(UIImage *)image blurRadius:(CGFloat)blurRadius completionBlock:(BlurredImageCompletionBlock)completion;

@end
