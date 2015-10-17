//
//  MiaRequestItem.m
//  mia
//
//  Created by linyehui on 2015/10/16.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "MiaRequestItem.h"

@implementation MiaRequestItem

- (instancetype)initWithTimeStamp:(long)timestamp
						  command:(NSString *)command
					  jsonString:(NSString *)jsonString
					completeBlock:(MiaRequestCompleteBlock)completeBlock
					 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	if (self = [super init]) {
		_timestamp = timestamp;
		_command = [command copy];
		_jsonString = [jsonString copy];
		_completeBlock = [completeBlock copy];
		_timeoutBlock = [timeoutBlock copy];
	}

	return self;
}

- (instancetype)copyWithZone:(nullable NSZone *)zone {
	MiaRequestItem *copyItem = [[[self class] allocWithZone:zone] initWithTimeStamp:_timestamp
																			command:_command
																		 jsonString:_jsonString
																	  completeBlock:_completeBlock
																	   timeoutBlock:_timeoutBlock];
	return copyItem;
}

@end
