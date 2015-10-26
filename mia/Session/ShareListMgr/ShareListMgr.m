//
//  ShareListMgr.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "ShareListMgr.h"
#import "PathHelper.h"
#import "UserSession.h"
#import "FileLog.h"

const int kShareListCapacity					= 25;
const int kHistoryItemsMaxCount					= 5;
const int kNeedGetNearbyCount					= 2;	// 至少两首，因为默认情况下会有两首新歌和界面元素绑定:current, right

@implementation ShareListMgr {
}

+ (id)initFromArchive {
	ShareListMgr * aMgr = [NSKeyedUnarchiver unarchiveObjectWithFile:[PathHelper shareArchivePathWithUID:[[UserSession standard] uid]]];
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

- (ShareItem *)getCurrentItem {
	if ([_shareList count] == 0
        || _currentItem > [_shareList count]) {
        return [ShareItem new];
	}

	return [_shareList objectAtIndex:_currentItem];
}

- (ShareItem *)getLeftItem {
	NSInteger leftIndex = _currentItem - 1;
	if (leftIndex < 0) {
		return [ShareItem new];
	} else {
		return [_shareList objectAtIndex:leftIndex];
	}
}

- (ShareItem *)getRightItem {
	NSInteger rightIndex = _currentItem + 1;
    if (rightIndex >= [_shareList count]) {
        return [ShareItem new];
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
	if (newIndex >= [_shareList count]) {
		[[FileLog standard] log:@"cursorShiftRight failed: %d, %lu", newIndex, [_shareList count]];
		return  NO;
	}

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
	if (([_shareList count] - _currentItem) <= kNeedGetNearbyCount){
		return YES;
	}

	return NO;
}

- (void)addSharesWithArray:(NSArray *) shareList {
	if ([shareList count] <= 0) {
		[[FileLog standard] log:@"getNearby shareList count is 0"];
		return;
	}

	for(id item in shareList){
		ShareItem *shareItem = [[ShareItem alloc] initWithDictionary:item];
		//NSLog(@"%@", shareItem);
		[_shareList addObject:shareItem];
	}
	[self saveChanges];
}

- (BOOL)saveChanges {
	NSString *fileName = [PathHelper shareArchivePathWithUID:[[UserSession standard] uid]];
	if (![NSKeyedArchiver archiveRootObject:self toFile:fileName]) {
		NSLog(@"archive share list failed.");
		if ([[NSFileManager defaultManager] removeItemAtPath:fileName error:nil]) {
			NSLog(@"delete share list archive file.");
		}
		return NO;
	}

	return YES;
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
	NSInteger overCount = _currentItem - kHistoryItemsMaxCount;
	if (overCount > 0) {
		for (NSInteger i = 0; i < overCount; i++) {
			[_shareList removeObjectAtIndex:0];
			_currentItem--;
		}
		
		[self saveChanges];
	}
}

@end
