//
//  NSString+DateFormatter.h
//
//  Created by linyehui on 14-8-7.
//
//

#import <Foundation/Foundation.h>

@interface NSString (DateFormatter)

/**
 *  秒数转为指定的日期格式
 *
 *  @param secondTime 秒数
 *  @param formater   时间格式
 *
 */
+(id)dateFormatterWithSecondTime:(NSTimeInterval )secondTime formatter:(NSString *)formater;

@end
