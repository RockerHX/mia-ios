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
		self.uID = [dictionary objectForKey:@"uID"];
		self.sNick = [dictionary objectForKey:@"sNick"];
		self.sDate = [dictionary objectForKey:@"sDate"];
		self.sNote = [dictionary objectForKey:@"sNote"];
		self.mID = [dictionary objectForKey:@"mID"];
		self.fID = [dictionary objectForKey:@"fID"];

		self.music = [[MusicItem alloc] initWithDictionary:[dictionary objectForKey:@"music"]];

		// 服务器不返回的数据
		self.isSelected = NO;
		self.isPlaying = NO;
    }
	
    return self;
}

@end
