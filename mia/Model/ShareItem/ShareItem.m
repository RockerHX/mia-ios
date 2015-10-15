//
//  ShareItem.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "ShareItem.h"
#import "InfectUserItem.h"

@implementation ShareItem

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if(self) {
		self.spID = [dictionary objectForKey:@"spID"];
		self.sID = [dictionary objectForKey:@"sID"];
		self.uID = [dictionary objectForKey:@"uID"];
		self.sNick = [dictionary objectForKey:@"sNick"];
		self.sNote = [dictionary objectForKey:@"sNote"];
		self.sAddress = [dictionary objectForKey:@"sAddress"];
		self.sLongitude = [dictionary objectForKey:@"sLongitude"];
		self.sLatitude = [dictionary objectForKey:@"sLatitude"];
		self.cView = [[dictionary objectForKey:@"cView"] intValue];
		self.cComm = [[dictionary objectForKey:@"cComm"] intValue];
		self.newCommCnt = [[dictionary objectForKey:@"newCommCnt"] intValue];
		self.favorite = [[dictionary objectForKey:@"star"] intValue];

		self.music = [[MusicItem alloc] initWithDictionary:[dictionary objectForKey:@"music"]];
		[self parseInfectUsersFromJsonArray:[dictionary objectForKey:@"infectList"]];

		self.unread = YES;
    }
	
    return self;
}

- (void)parseInfectUsersFromJsonArray:(NSArray *)jsonArray {
	NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:[jsonArray count]];
	if (!jsonArray || [jsonArray count] == 0) {
		return;
	}

	for (NSDictionary *dicItem in jsonArray) {
		InfectUserItem *userItem = [[InfectUserItem alloc] initWithDictionary:dicItem];
		[resultArray addObject:userItem];
	}

	_infectUsers = resultArray;
}

//将对象编码(即:序列化)
- (void) encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.spID forKey:@"spID"];
	[aCoder encodeObject:self.sID forKey:@"sID"];
	[aCoder encodeObject:self.uID forKey:@"uID"];
	[aCoder encodeObject:self.sNick forKey:@"sNick"];
	[aCoder encodeObject:self.sNote forKey:@"sNote"];
	[aCoder encodeObject:self.sAddress forKey:@"sAddress"];
	[aCoder encodeObject:self.sLongitude forKey:@"sLongitude"];
	[aCoder encodeObject:self.sLatitude forKey:@"sLatitude"];
	[aCoder encodeObject:self.music forKey:@"music"];
	[aCoder encodeObject:self.infectUsers forKey:@"infectUsers"];
	[aCoder encodeInt:self.cView forKey:@"cView"];
	[aCoder encodeInt:self.cComm forKey:@"cComm"];
	[aCoder encodeInt:self.newCommCnt forKey:@"newCommCnt"];
	[aCoder encodeBool:self.unread forKey:@"unread"];
	[aCoder encodeBool:self.favorite forKey:@"favorite"];
}

//将对象解码(反序列化)
-(id) initWithCoder:(NSCoder *)aDecoder {
	if (self=[super init]) {
		self.spID = [aDecoder decodeObjectForKey:@"spID"];
		self.sID = [aDecoder decodeObjectForKey:@"sID"];
		self.uID = [aDecoder decodeObjectForKey:@"uID"];
		self.sNick = [aDecoder decodeObjectForKey:@"sNick"];
		self.sNote = [aDecoder decodeObjectForKey:@"sNote"];
		self.sAddress = [aDecoder decodeObjectForKey:@"sAddress"];
		self.sLongitude = [aDecoder decodeObjectForKey:@"sLongitude"];
		self.sLatitude = [aDecoder decodeObjectForKey:@"sLatitude"];
		self.music = [aDecoder decodeObjectForKey:@"music"];
		self.infectUsers = [aDecoder decodeObjectForKey:@"infectUsers"];
		self.cView = [aDecoder decodeIntForKey:@"cView"];
		self.cComm = [aDecoder decodeIntForKey:@"cComm"];
		self.newCommCnt = [aDecoder decodeIntForKey:@"newCommCnt"];
		self.unread = [aDecoder decodeBoolForKey:@"unread"];
		self.favorite = [aDecoder decodeBoolForKey:@"favorite"];
	}

	return (self);

}

@end
