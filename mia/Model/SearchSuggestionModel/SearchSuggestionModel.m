//
//  SearchSuggestionModel.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "SearchSuggestionModel.h"

@implementation SearchSuggestionModel

- (id)init {
	self = [super init];
	if(self) {
		_dataSource = [[NSMutableArray alloc] init];
	}

	return self;
}

- (void)addItemsWithArray:(NSArray *) items {
	[_dataSource addObjectsFromArray:items];
}

@end
