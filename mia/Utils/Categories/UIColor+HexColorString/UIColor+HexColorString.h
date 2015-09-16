//
//  UIColor+HexColorString.h
//
//  Created by linyehui on 14-8-12.
//
//

#import <UIKit/UIKit.h>

@interface UIColor (HexColorString)

/**
 *  十六进制颜色值转UIColor
 *
 *  @param hexColorString 十六进制颜色值
 *  @param alpha          透明度
 *
 */
+(UIColor *)colorWithHexColorString:(NSString *)hexColorString alpha:(float)alpha;

@end
