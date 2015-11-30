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

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
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
		self.infectTotal = [[dictionary objectForKey:@"infectTotal"] intValue];
		self.favorite = [[dictionary objectForKey:@"star"] intValue];
		self.isInfected = [[dictionary objectForKey:@"isInfected"] intValue];

		self.music = [MusicItem mj_objectWithKeyValues:[dictionary objectForKey:@"music"]];
		[self parseInfectUsersFromJsonArray:[dictionary objectForKey:@"infectList"]];
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
- (void)encodeWithCoder:(NSCoder *)aCoder {
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
	[aCoder encodeInt:self.infectTotal forKey:@"infectTotal"];
	[aCoder encodeBool:self.favorite forKey:@"favorite"];
	[aCoder encodeBool:self.isInfected forKey:@"isInfected"];
}

//将对象解码(反序列化)
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
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
		self.infectTotal = [aDecoder decodeIntForKey:@"infectTotal"];
		self.favorite = [aDecoder decodeBoolForKey:@"favorite"];
		self.isInfected = [aDecoder decodeBoolForKey:@"isInfected"];
	}

	return (self);

}

#pragma mark - Setter And Getter
- (BOOL)hasData {
    return _sID ? YES : NO;
}

@end
