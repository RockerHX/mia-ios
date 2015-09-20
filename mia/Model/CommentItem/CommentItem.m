//
//  CommentItem.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "CommentItem.h"

@implementation CommentItem

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if(self) {
		self.userName = [dictionary objectForKey:@"name"];
		self.userAvatar = [dictionary objectForKey:@"avatar"];
		self.comment = [dictionary objectForKey:@"comment"];
    }
	
    return self;
}


@end
