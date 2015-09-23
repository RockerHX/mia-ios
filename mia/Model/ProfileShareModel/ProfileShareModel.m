//
//  ProfileShareModel.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "ProfileShareModel.h"
#import "ShareItem.h"

@implementation ProfileShareModel

- (id)init {
	self = [super init];
	if(self) {
		_dataSource = [[NSMutableArray alloc] init];
	}

	return self;
}

- (void)addSharesWithArray:(NSArray *) shareList {
	for(id item in shareList){
		ShareItem *shareItem = [[ShareItem alloc] initWithDictionary:item];
		//NSLog(@"%@", shareItem);
		[_dataSource addObject:shareItem];
	}
}

@end
