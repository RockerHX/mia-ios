//
//  UserItem.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "UserItem.h"
#import "NSString+IsNull.h"

@implementation UserItem

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if(self) {
		self.uid = [dictionary objectForKey:@"uID"];
		self.nick = [dictionary objectForKey:@"nick"];
		self.userpic = [dictionary objectForKey:@"userpic"];
		self.sharem = [dictionary objectForKey:@"sharem"];
		if ([NSString isNull:self.sharem]) {
			self.sharem = @"";
		}
		
		self.follow = [[dictionary objectForKey:@"follow"] intValue];
    }
	
    return self;
}

- (instancetype)copyWithZone:(nullable NSZone *)zone {
	UserItem *copyItem = [[[self class] allocWithZone:zone] init];
	copyItem.uid = [_uid copy];
	copyItem.nick = [_nick copy];
	copyItem.userpic = [_userpic copy];
	copyItem.sharem = [_sharem copy];
	copyItem.follow = _follow;

	return copyItem;
}


//将对象编码(即:序列化)
- (void) encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.uid forKey:@"uid"];
	[aCoder encodeObject:self.nick forKey:@"nick"];
	[aCoder encodeObject:self.userpic forKey:@"userpic"];
	[aCoder encodeObject:self.sharem forKey:@"sharem"];
	[aCoder encodeBool:self.follow forKey:@"follow"];
}

//将对象解码(反序列化)
- (id) initWithCoder:(NSCoder *)aDecoder {
	if (self=[super init]) {
		self.uid = [aDecoder decodeObjectForKey:@"uid"];
		self.nick = [aDecoder decodeObjectForKey:@"nick"];
		self.userpic = [aDecoder decodeObjectForKey:@"userpic"];
		self.sharem = [aDecoder decodeObjectForKey:@"sharem"];
		self.follow = [aDecoder decodeBoolForKey:@"follow"];
	}

	return (self);

}


@end
