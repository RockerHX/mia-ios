//
//  FriendModel.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "FriendModel.h"

@implementation FriendModel

- (id)init {
	self = [super init];
	if(self) {
		_dataSource = [[NSMutableArray alloc] init];
		_currentPage = 0;
	}

	return self;
}

- (void)addItemsWithArray:(NSArray *) items {
	[_dataSource addObjectsFromArray:items];
}

- (void)reset {
	[_dataSource removeAllObjects];
	_currentPage = 0;
}
@end
