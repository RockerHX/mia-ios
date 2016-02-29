//
//  LastCommentItem.m
//
//
//  Created by linyehui on 2016/02/29.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "LastCommentItem.h"

@implementation LastCommentItem

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if(self) {
		if ([dictionary isKindOfClass:[NSNull class]]) {
			return nil;
		}
		
		self.comment = [dictionary objectForKey:@"comment"];
		self.uID = [dictionary objectForKey:@"uID"];
		self.nick = [dictionary objectForKey:@"nick"];
		self.time = [[dictionary objectForKey:@"time"] integerValue];
    }
	
    return self;
}

//将对象编码(即:序列化)
- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.comment forKey:@"comment"];
	[aCoder encodeObject:self.uID forKey:@"uID"];
	[aCoder encodeObject:self.nick forKey:@"nick"];
	[aCoder encodeInteger:self.time forKey:@"time"];
}

//将对象解码(反序列化)
- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self=[super init]) {
		self.comment = [aDecoder decodeObjectForKey:@"comment"];
		self.uID = [aDecoder decodeObjectForKey:@"uID"];
		self.nick = [aDecoder decodeObjectForKey:@"nick"];
		self.time = [aDecoder decodeIntegerForKey:@"time"];
	}

	return (self);

}


@end
