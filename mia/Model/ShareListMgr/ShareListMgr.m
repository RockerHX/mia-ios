//
//  ShareListMgr.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "ShareListMgr.h"

const int kShareListMax							= 10;

@implementation ShareListMgr {
	NSMutableArray *onlineShareList;
	NSMutableArray *offlineShareList;
	ShareItem *currentShareItem;
}

- (id)initFromArchive {
	// TODO 要试下能否直接archive 这个对象本身，这样就不需要分两个文件来保存了
//	self = ....
//	if (self) {
//		return self;
//	}

    self = [super init];
    if(self) {
		// load data from archive

		onlineShareList = [NSKeyedUnarchiver unarchiveObjectWithFile:[self onlineShareListArchivePath]];
		NSLog(@"%@", onlineShareList);
		if (!onlineShareList) {
			onlineShareList = [[NSMutableArray alloc] initWithCapacity:kShareListMax];
		}

    }
	
    return self;
}

- (NSUInteger)getOnlineCount {
	return [onlineShareList count];
}

- (void)addSharesWithArray:(NSArray *) shareList {
	for(id item in shareList){
		ShareItem *shareItem = [[ShareItem alloc] initWithDictionary:item];
		//NSLog(@"%@", shareItem);
		[onlineShareList addObject:shareItem];
	}

	if (![NSKeyedArchiver archiveRootObject:onlineShareList toFile:[self onlineShareListArchivePath]]) {
		NSLog(@"archive online share list failed.");
	}

}

- (ShareItem *)popShareItem {
	currentShareItem = [onlineShareList objectAtIndex:0];
	[onlineShareList removeObjectAtIndex:0];

	return currentShareItem;
}


- (BOOL)saveChanges {
	// TODO
	if (![NSKeyedArchiver archiveRootObject:onlineShareList toFile:[self onlineShareListArchivePath]]) {
		NSLog(@"archive online share list failed.");
		return NO;
	}

	return YES;
}

- (NSString *)onlineShareListArchivePath {
	NSArray *documentDirectores = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [documentDirectores objectAtIndex:0];

	return [documentDirectory stringByAppendingString:@"onlinelist.archive"];
}

@end
