//
//  NSString+Emoji.h
//
//  Created by linyehui on 14-8-12.
//
//

#import <Foundation/Foundation.h>

@interface NSString (Emoji)

/**
 *  禁止输入Emoji表情符号
 *
 *  @param text         原文
 *
 */
+(NSString *)disableEmoji:(NSString *)text;

/**
 *  判断是否包含emoji表情
 *
 *  @param text 原文
 *
 */
+(BOOL)isContainsEmoji:(NSString *)text;

@end
