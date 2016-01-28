//
//  MessageModel.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "MessageModel.h"
#import "MessageItem.h"

static NSString *kDefaultMessageLastID = @"0";

@implementation MessageModel

- (id)init {
	self = [super init];
	if(self) {
		_dataSource = [[NSMutableArray alloc] init];
		_lastID = kDefaultMessageLastID;
	}

	return self;
}

- (void)addItemsWithArray:(NSArray *) items {
	for(id item in items) {
		MessageItem *dataItem = [MessageItem mj_objectWithKeyValues:item];
		[_dataSource addObject:dataItem];

		NSLog(@"time: %@", dataItem.formatTime);

		_lastID = dataItem.notifyID;
	}
}

- (void)reset {
	[_dataSource removeAllObjects];
	_lastID = kDefaultMessageLastID;
}
@end
