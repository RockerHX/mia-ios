//
//  FavoriteItem.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "FavoriteItem.h"
#import "ShareItem.h"
#import "PathHelper.h"
#import "UserSetting.h"

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

		self.spID = [dictionary objectForKey:@"spID"];
		self.isInfected = [[dictionary objectForKey:@"isInfected"] intValue];
		self.time = [[dictionary objectForKey:@"time"] integerValue];

		self.music = [[MusicItem alloc] initWithDictionary:[dictionary objectForKey:@"music"]];

		// 服务器不返回的数据
		self.isSelected = NO;
		self.isPlaying = NO;
		self.isCached = NO;
    }
	
    return self;
}

- (ShareItem *)shareItem {
	ShareItem *item = [[ShareItem alloc] init];

	item.spID = self.spID;
	item.sID = self.sID;
	item.uID = self.uID;
	item.sNick = self.sNick;
	item.sNote = self.sNote;
	item.time = self.time;
	item.music = [self.music copy];
	item.favorite = YES;
	item.isInfected = self.isInfected;

	if (self.isCached) {
		item.music.murl = [UserSetting pathWithPrefix:[PathHelper genMusicFilenameWithUrl:self.music.murl]];
	}

	return item;
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

	[aCoder encodeObject:self.spID forKey:@"spID"];
	[aCoder encodeBool:self.isInfected forKey:@"isInfected"];
	[aCoder encodeInteger:self.time forKey:@"time"];

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

		self.spID = [aDecoder decodeObjectForKey:@"spID"];
		self.isInfected = [aDecoder decodeBoolForKey:@"isInfected"];
		self.time = [aDecoder decodeIntegerForKey:@"time"];

		self.music = [aDecoder decodeObjectForKey:@"music"];

		self.isCached = [aDecoder decodeBoolForKey:@"isCached"];
	}

	return (self);

}

@end
