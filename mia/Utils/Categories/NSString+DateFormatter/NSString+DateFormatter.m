//
//  NSString+DateFormatter.m
//
//  Created by linyehui on 14-8-7.
//
//

#import "NSString+DateFormatter.h"

@implementation NSString (DateFormatter)

/**
 *  秒数转为指定的日期格式
 *
 *  @param secondTime 秒数
 *  @param formater   时间格式
 *
 */
+(id)dateFormatterWithSecondTime:(NSTimeInterval )secondTime formatter:(NSString *)formater{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = formater;
    NSDate *localeDate = [[NSDate alloc] initWithTimeIntervalSince1970:secondTime];
    return [formatter stringFromDate:localeDate];
}
@end
