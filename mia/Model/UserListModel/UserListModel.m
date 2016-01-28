//
//  UserListModel.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "UserListModel.h"
#import "UserItem.h"

static const long kDefaultUserListStartPage = 1;

@implementation UserListModel

- (id)init {
	self = [super init];
	if(self) {
		_dataSource = [[NSMutableArray alloc] init];
		_currentPage = kDefaultUserListStartPage;
	}

	return self;
}

- (void)addItemsWithArray:(NSArray *) items {
	for(id item in items) {
		UserItem *dataItem = [[UserItem alloc] initWithDictionary:item];
		[_dataSource addObject:dataItem];
	}
}

- (void)reset {
	[_dataSource removeAllObjects];
	_currentPage = kDefaultUserListStartPage;
}
@end
