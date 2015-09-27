//
//  FavoriteModel.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "FavoriteModel.h"
#import "ShareItem.h"

@implementation FavoriteModel

- (id)init {
	self = [super init];
	if(self) {
		_dataSource = [[NSMutableArray alloc] init];
	}

	return self;
}

- (void)addItemsWithArray:(NSArray *) items {
	for(id item in items){
		ShareItem *shareItem = [[ShareItem alloc] initWithDictionary:item];
		//NSLog(@"%@", shareItem);
		[_dataSource addObject:shareItem];
	}
}

@end
