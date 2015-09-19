//
//  ShareListMgr.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "ShareListMgr.h"

const int kShareListCapacity					= 25;
const int kHasViewedItemsMax					= 15;
const int kNeedGetNearbyCount					= 1;

@implementation ShareListMgr {
}

+ (id)initFromArchive {
	ShareListMgr * aMgr = [NSKeyedUnarchiver unarchiveObjectWithFile:[self archivePath]];
	if (!aMgr) {
	    aMgr = [[self alloc] init];
	}
	
    return aMgr;
}

- (id)init {
	self = [super init];
	if (self) {
		_shareList = [[NSMutableArray alloc] initWithCapacity:kShareListCapacity];
	}

	return self;
}

- (NSUInteger)getHasNotViewedCount {
	NSUInteger count = 0;
	for (ShareItem *item in _shareList) {
		if (!item.hasViewed) {
			count++;
		}
	}

	return count;
}

- (ShareItem *)getCurrentItem {
	return [_shareList objectAtIndex:_currentItem];
}

- (ShareItem *)getLeftItem {
	NSInteger leftIndex = _currentItem - 1;
	if (leftIndex < 0) {
		return nil;
	} else {
		return [_shareList objectAtIndex:leftIndex];
	}
}

- (ShareItem *)getRightItem {
	NSInteger rightIndex = _currentItem + 1;
	if (rightIndex >= [_shareList count]) {
		return nil;
	} else {
		return [_shareList objectAtIndex:rightIndex];
	}
}

- (BOOL)isNeedGetNearbyItems {
	if ([self getHasNotViewedCount] <= kNeedGetNearbyCount) {
		return YES;
	} else {
		return NO;
	}
}

- (void)addSharesWithArray:(NSArray *) shareList {
	for(id item in shareList){
		ShareItem *shareItem = [[ShareItem alloc] initWithDictionary:item];
		//NSLog(@"%@", shareItem);
		[_shareList addObject:shareItem];
	}
}

//- (ShareItem *)popItemFromRight {
//	_currentShareItem = [_shareList objectAtIndex:0];
//	[_shareList removeObjectAtIndex:0];
//
//	return _currentShareItem;
//}
//

- (BOOL)saveChanges {
	// TODO
	if (![NSKeyedArchiver archiveRootObject:self toFile:[ShareListMgr archivePath]]) {
		NSLog(@"archive online share list failed.");
		return NO;
	}

	return YES;
}

+ (NSString *)archivePath {
	NSArray *documentDirectores = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [documentDirectores objectAtIndex:0];

	return [documentDirectory stringByAppendingString:@"sharelist.archive"];
}

//将对象编码(即:序列化)
- (void) encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:_shareList forKey:@"shareList"];
	[aCoder encodeInteger:_currentItem forKey:@"currentItem"];
}

//将对象解码(反序列化)
-(id) initWithCoder:(NSCoder *)aDecoder {
	if (self=[super init]) {
		_shareList = [aDecoder decodeObjectForKey:@"shareList"];
		_currentItem = [aDecoder decodeIntegerForKey:@"currentItem"];
	}

	return (self);

}

@end
