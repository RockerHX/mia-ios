//
//  FavoriteItem.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "FavoriteItem.h"

@implementation FavoriteItem

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if(self) {
		self.sID = [dictionary objectForKey:@"sID"];
		self.uID = [dictionary objectForKey:@"uID"];
		self.sNick = [dictionary objectForKey:@"sNick"];
		self.sDate = [dictionary objectForKey:@"sDate"];
		self.sNote = [dictionary objectForKey:@"sNote"];
		self.mID = [dictionary objectForKey:@"mID"];
		self.fID = [dictionary objectForKey:@"fID"];

		self.music = [[MusicItem alloc] initWithDictionary:[dictionary objectForKey:@"music"]];

		// 服务器不返回的数据
		self.isSelected = NO;
		self.isCached = NO;
    }
	
    return self;
}

//将对象编码(即:序列化)
- (void) encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.sID forKey:@"sID"];
	[aCoder encodeObject:self.uID forKey:@"uID"];
	[aCoder encodeObject:self.sNick forKey:@"sNick"];
	[aCoder encodeObject:self.sDate forKey:@"sDate"];
	[aCoder encodeObject:self.sNote forKey:@"sNote"];
	[aCoder encodeObject:self.mID forKey:@"mID"];
	[aCoder encodeObject:self.fID forKey:@"fID"];
	[aCoder encodeObject:self.music forKey:@"music"];

	[aCoder encodeBool:self.isCached forKey:@"isCached"];
}

//将对象解码(反序列化)
-(id) initWithCoder:(NSCoder *)aDecoder {
	if (self=[super init]) {
		self.sID = [aDecoder decodeObjectForKey:@"sID"];
		self.uID = [aDecoder decodeObjectForKey:@"uID"];
		self.sNick = [aDecoder decodeObjectForKey:@"sNick"];
		self.sDate = [aDecoder decodeObjectForKey:@"sDate"];
		self.sNote = [aDecoder decodeObjectForKey:@"sNote"];
		self.mID = [aDecoder decodeObjectForKey:@"mID"];
		self.fID = [aDecoder decodeObjectForKey:@"fID"];
		self.music = [aDecoder decodeObjectForKey:@"music"];

		self.isCached = [aDecoder decodeBoolForKey:@"isCached"];
	}

	return (self);

}

@end
