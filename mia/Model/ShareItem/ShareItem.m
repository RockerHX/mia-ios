//
//  ShareItem.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "ShareItem.h"

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

		self.music = [[MusicItem alloc] initWithDictionary:[dictionary objectForKey:@"music"]];
    }
	
    return self;
}

@end
