//
//  MusicItem.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "MusicItem.h"

@implementation MusicItem

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if(self) {
		self.mid = [dictionary objectForKey:@"mid"];
		self.singerID = [dictionary objectForKey:@"singerID"];
		self.singerName = [dictionary objectForKey:@"singerName"];
		self.albumName = [dictionary objectForKey:@"albumName"];
		self.name = [dictionary objectForKey:@"name"];
		self.purl = [dictionary objectForKey:@"purl"];
		self.murl = [dictionary objectForKey:@"murl"];
		self.flag = [dictionary objectForKey:@"flag"];
    }
	
    return self;
}

@end
