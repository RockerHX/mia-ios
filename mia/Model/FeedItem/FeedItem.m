//
//  FeedItem.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "FeedItem.h"

@implementation FeedItem

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if(self) {
		self.sID = [dictionary objectForKey:@"sID"];
		self.mID = [dictionary objectForKey:@"mID"];
		self.uID = [dictionary objectForKey:@"uID"];
		self.sGeohash = [dictionary objectForKey:@"sGeohash"];
		self.freeChanceNum = [dictionary objectForKey:@"freeChanceNum"];
		self.sAddress = [dictionary objectForKey:@"sAddress"];
		self.sNick = [dictionary objectForKey:@"sNick"];
		self.sRemoteip = [dictionary objectForKey:@"sRemoteip"];
		self.sNote = [dictionary objectForKey:@"sNote"];

		self.cStar = [[dictionary objectForKey:@"cStar"] intValue];
		self.cView = [[dictionary objectForKey:@"cView"] intValue];
		self.cComm = [[dictionary objectForKey:@"cComm"] intValue];
		self.cShare = [[dictionary objectForKey:@"cShare"] intValue];
    }
	
    return self;
}

@end
