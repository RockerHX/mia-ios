//
//  HXComment.m
//  mia
//
//  Created by miaios on 15/10/27.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXComment.h"
#import "DateTools.h"

@implementation HXComment

+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{@"nickName": @"unick",
            @"headerURL": @"uimg",
             @"time": @"time",
			 @"cmid": @"cmid",
              @"content": @"cinfo"};
}

- (instancetype)copyWithZone:(nullable NSZone *)zone {
	HXComment *copyItem = [[[self class] allocWithZone:zone] init];
	copyItem.cmid = [_cmid copy];
	copyItem.uid = [_uid copy];
	copyItem.nickName = [_nickName copy];
	copyItem.headerURL = [_headerURL copy];
	copyItem.content = [_content copy];
	copyItem.time = _time;

	return copyItem;
}

#pragma mark - Setter And Getter
- (NSString *)formatTime {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_time];
    NSInteger hours = [date hoursEarlierThan:[NSDate date]];
    NSString *prompt = @"刚刚";
    if (hours <= 0) {
        prompt = @"刚刚";
    } else if (hours > 0 && hours <= 24) {
        prompt = [NSString stringWithFormat:@"%zd小时前", hours];
    } else {
        NSInteger days = [date daysEarlierThan:[NSDate date]];
        if (days < 10) {
            prompt = [NSString stringWithFormat:@"%zd天前", days];
        } else {
            prompt = [date formattedDateWithFormat:@"yyyy-MM-dd hh:mm:ss"];
        }
    }
    return prompt;
}

@end
