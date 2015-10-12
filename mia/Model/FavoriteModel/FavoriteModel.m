//
//  FavoriteModel.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "FavoriteModel.h"
#import "FavoriteItem.h"

@implementation FavoriteModel

- (id)init {
	self = [super init];
	if(self) {
		_dataSource = [[NSMutableArray alloc] init];
	}

	return self;
}

- (void)addItemsWithArray:(NSArray *) items {
	if (items.count <= 0) {
		return;
	}
	
	[_dataSource addObjectsFromArray:items];
}

@end
