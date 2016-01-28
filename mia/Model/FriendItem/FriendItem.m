//
//  FriendItem.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "FriendItem.h"

@implementation FriendItem

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if(self) {
		_isPlaying = NO;
    }
	
    return self;
}

@end
