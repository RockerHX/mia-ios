//
//  CommentItem.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "CommentItem.h"

@implementation CommentItem

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if(self) {
		self.cmid = [dictionary objectForKey:@"cmid"];
		self.uid = [dictionary objectForKey:@"uid"];
		self.unick = [dictionary objectForKey:@"unick"];
		self.uimg = [dictionary objectForKey:@"uimg"];
		self.date = [dictionary objectForKey:@"date"];
		self.edate = [dictionary objectForKey:@"edate"];
		self.cinfo = [dictionary objectForKey:@"cinfo"];
	}
	
    return self;
}


@end
