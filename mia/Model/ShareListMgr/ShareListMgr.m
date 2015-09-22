//
//  ShareListMgr.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "ShareListMgr.h"

const int kShareListCapacity					= 25;
const int kHistoryItemsMaxCount					= 5;
const int kNeedGetNearbyCount					= 2;	// 至少两首，因为默认情况下会有两首新歌和界面元素绑定:current, right

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

- (NSUInteger)getUnreadCount {
	NSUInteger count = 0;
	for (ShareItem *item in _shareList) {
		if (item.unread) {
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

- (BOOL)cursorShiftLeft {
	NSInteger newIndex = _currentItem - 1;
	if (newIndex <= 0)
		return NO;

	_currentItem = newIndex;
	[self saveChanges];
	return YES;
}

- (BOOL)cursorShiftRight {
	NSInteger newIndex = _currentItem + 1;
	if (newIndex >= [_shareList count])
		return  NO;

	_currentItem = newIndex;
	[self saveChanges];

	return YES;
}

- (BOOL)cursorShiftRightWithRemoveCurrent {
	// 简单处理，如果是最后一个元素，不允许删除
	// 这个逻辑通过及时获取列表来规避
	if ((_currentItem + 1) >= [_shareList count]) {
		NSLog(@"no more item at right, you need to request more.");
		return NO;
	}

	[_shareList removeObjectAtIndex:_currentItem];
	[self saveChanges];

	return YES;
}


- (BOOL)isNeedGetNearbyItems {
	if ([self getUnreadCount] <= kNeedGetNearbyCount) {
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
	[self saveChanges];
}

//- (ShareItem *)popItemFromRight {
//	_currentShareItem = [_shareList objectAtIndex:0];
//	[_shareList removeObjectAtIndex:0];
//
//	return _currentShareItem;
//}
//

- (BOOL)saveChanges {
	NSString *fileName = [ShareListMgr archivePath];
	if (![NSKeyedArchiver archiveRootObject:self toFile:fileName]) {
		NSLog(@"archive share list failed.");
		if ([[NSFileManager defaultManager] removeItemAtPath:fileName error:nil]) {
			NSLog(@"delete share list archive file.");
		}
		return NO;
	}

	return YES;
}

+ (NSString *)archivePath {
	NSArray *documentDirectores = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [documentDirectores objectAtIndex:0];

	return [documentDirectory stringByAppendingString:@"/sharelist.archive"];
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

- (void)checkHistoryItemsMaxCount {
	NSUInteger count = 0;
	for (ShareItem *item in _shareList) {
		if (!item.unread) {
			count++;
		}
	}

	NSInteger overCount = count - kHistoryItemsMaxCount;
	if (overCount > 0) {
		for (NSInteger i = 0; i < overCount; i++) {
			[_shareList removeObjectAtIndex:0];
			_currentItem--;
		}
	}
}

@end
