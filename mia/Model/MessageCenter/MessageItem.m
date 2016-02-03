//
//  MessageItem.m
//  mia
//
//  Created by miaios on 16/1/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "MessageItem.h"
#import "FormatTimeHelper.h"

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
	return [FormatTimeHelper formatTimeWith:_time];
}


@end
