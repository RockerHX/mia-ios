//
//  InfectItem.m
//  用于InfectList的Item封装
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "InfectItem.h"

@implementation InfectItem

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if(self) {
		self.infectid = [dictionary objectForKey:@"infectid"];
		self.uID = [dictionary objectForKey:@"uID"];
		self.nick = [dictionary objectForKey:@"nick"];
		self.avatar = [dictionary objectForKey:@"userpic"];
		self.lastShare = [dictionary objectForKey:@"sharem"];
    }
	
    return self;
}

@end
