//
//  HXComment.m
//  mia
//
//  Created by miaios on 15/10/27.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXComment.h"
#import "FormatTimeHelper.h"

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
	return [FormatTimeHelper formatTimeWith:_time];
}

@end
