//
//  MessageItem.m
//  mia
//
//  Created by miaios on 16/1/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "MessageItem.h"
#import "DateTools.h"

@implementation MessageItem

+ (NSDictionary *)replacedKeyFromPropertyName {
	return @{@"notifyID": @"notifyID",
			 @"hasReaded": @"status"};
}

#pragma mark - Setter And Getter
- (BOOL)navigateToUser {
    return (_ntype == 8);
}

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
