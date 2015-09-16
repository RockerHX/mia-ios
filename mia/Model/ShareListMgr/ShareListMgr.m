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
}

+ (id)initFromArchive {
	ShareListMgr * aMgr = [NSKeyedUnarchiver unarchiveObjectWithFile:[self onlineShareListArchivePath]];
	if (!aMgr) {
	    aMgr = [[self alloc] init];
	}
	
    return aMgr;
}

- (id)init {
	self = [super init];
	if (self) {
		_onlineShareList = [[NSMutableArray alloc] initWithCapacity:kShareListMax];
		_offlineShareList = [[NSMutableArray alloc] initWithCapacity:kShareListMax];
	}

	return self;
}

- (NSUInteger)getOnlineCount {
	return [_onlineShareList count];
}

- (void)addSharesWithArray:(NSArray *) shareList {
	for(id item in shareList){
		ShareItem *shareItem = [[ShareItem alloc] initWithDictionary:item];
		//NSLog(@"%@", shareItem);
		[_onlineShareList addObject:shareItem];
	}
}

- (ShareItem *)popShareItem {
	_currentShareItem = [_onlineShareList objectAtIndex:0];
	[_onlineShareList removeObjectAtIndex:0];

	return _currentShareItem;
}


- (BOOL)saveChanges {
	// TODO
	if (![NSKeyedArchiver archiveRootObject:self toFile:[ShareListMgr onlineShareListArchivePath]]) {
		NSLog(@"archive online share list failed.");
		return NO;
	}

	return YES;
}

+ (NSString *)onlineShareListArchivePath {
	NSArray *documentDirectores = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [documentDirectores objectAtIndex:0];

	return [documentDirectory stringByAppendingString:@"onlinelist.archive"];
}

//将对象编码(即:序列化)
- (void) encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.onlineShareList forKey:@"onlineList"];
	[aCoder encodeObject:self.offlineShareList forKey:@"offlineList"];
	[aCoder encodeObject:self.currentShareItem forKey:@"currentItem"];
}

//将对象解码(反序列化)
-(id) initWithCoder:(NSCoder *)aDecoder {
	if (self=[super init]) {
		self.onlineShareList = [aDecoder decodeObjectForKey:@"onlineList"];
		self.offlineShareList = [aDecoder decodeObjectForKey:@"offlineList"];
		self.currentShareItem = [aDecoder decodeObjectForKey:@"currentItem"];
	}

	return (self);

}

@end
