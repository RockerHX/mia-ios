//
//  SearchSuggestionModel.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "SearchSuggestionModel.h"
#import "FavoriteItem.h"

@implementation SearchSuggestionModel

- (id)init {
	self = [super init];
	if(self) {
		_dataSource = [[NSMutableArray alloc] init];
		_lastID = @"0";
	}

	return self;
}

- (void)addItemsWithArray:(NSArray *) items {
	for(id item in items){
		FavoriteItem *favoriteItem = [[FavoriteItem alloc] initWithDictionary:item];
		//NSLog(@"%@", favoriteItem);
		_lastID = favoriteItem.fID;
		[_dataSource addObject:favoriteItem];
	}
}

@end
