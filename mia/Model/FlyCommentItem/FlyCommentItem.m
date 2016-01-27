//
//  FlyCommentItem.m
//
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "FlyCommentItem.h"

@implementation FlyCommentItem

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if(self) {
		self.userpic = [dictionary objectForKey:@"userpic"];
		self.comment = [dictionary objectForKey:@"comment"];
		self.time = [[dictionary objectForKey:@"time"] integerValue];
    }
	
    return self;
}

//将对象编码(即:序列化)
- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.userpic forKey:@"userpic"];
	[aCoder encodeObject:self.comment forKey:@"comment"];
	[aCoder encodeInteger:self.time forKey:@"time"];
}

//将对象解码(反序列化)
- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self=[super init]) {
		self.userpic = [aDecoder decodeObjectForKey:@"userpic"];
		self.comment = [aDecoder decodeObjectForKey:@"comment"];
		self.time = [aDecoder decodeIntegerForKey:@"time"];
	}

	return (self);

}


@end
