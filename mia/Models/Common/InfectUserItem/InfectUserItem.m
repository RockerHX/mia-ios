//
//  InfectUserItem.m
//  用于显示妙推头像的Item封装
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "InfectUserItem.h"

@implementation InfectUserItem

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if(self) {
		self.uid = [dictionary objectForKey:@"uID"];
		self.avatar = [dictionary objectForKey:@"userpic"];
    }
	
    return self;
}

//将对象编码(即:序列化)
- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.uid forKey:@"uID"];
	[aCoder encodeObject:self.avatar forKey:@"userpic"];
}

//将对象解码(反序列化)
- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self=[super init]) {
		self.uid = [aDecoder decodeObjectForKey:@"uID"];
		self.avatar = [aDecoder decodeObjectForKey:@"userpic"];
	}

	return (self);

}

@end
