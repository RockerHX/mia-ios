//
//  ShareListMgr.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "ShareListMgr.h"
#import "PathHelper.h"
#import "FileLog.h"
#import "HXUserSession.h"

const int kShareListCapacity					= 25;
const int kHistoryItemsMaxCount					= 15;
const int kNeedGetNearbyCount					= 2;	// 至少两首，因为默认情况下会有两首新歌和界面元素绑定:current, right

@implementation ShareListMgr {
    NSMutableArray <ShareItem *> *_shareList;
}

@synthesize shareList = _shareList;

#pragma mark - Class Methods
+ (instancetype)initFromArchive {
	ShareListMgr * aMgr = [NSKeyedUnarchiver unarchiveObjectWithFile:[PathHelper shareArchivePathWithUID:[[HXUserSession share] uid]]];
	if (!aMgr) {
	    aMgr = [[self alloc] init];
	}
	
    return aMgr;
}

#pragma mark - Init Methods
- (instancetype)init {
	self = [super init];
	if (self) {
		_shareList = [[NSMutableArray alloc] initWithCapacity:kShareListCapacity];
	}

	return self;
}

#pragma mark - NSCoding
//将对象编码(即:序列化)
- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_shareList forKey:@"shareList"];
    [aCoder encodeInteger:_currentIndex forKey:@"currentItem"];
}

//将对象解码(反序列化)
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self=[super init]) {
        _shareList = [aDecoder decodeObjectForKey:@"shareList"];
        _currentIndex = [aDecoder decodeIntegerForKey:@"currentItem"];
    }
    return (self);
}

#pragma mark - Property
- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    [self saveChanges];
}

#pragma mark - Public Methods
- (BOOL)cursorShiftLeft {
    NSInteger newIndex = _currentIndex - 1;
    if (newIndex < 0) {
        return NO;
    }
    
    _currentIndex = newIndex;
    [self saveChanges];
    return YES;
}

- (BOOL)cursorShiftRight {
    NSInteger newIndex = _currentIndex + 1;
    if (newIndex >= _shareList.count) {
        [[FileLog standard] log:@"cursorShiftRight failed: %d, %lu", newIndex, [_shareList count]];
        return  NO;
    }
    
    _currentIndex = newIndex;
    [self saveChanges];
    
    return YES;
}

- (BOOL)isNeedGetNearbyItems {
	if (([_shareList count] - _currentIndex) <= kNeedGetNearbyCount){
		[[FileLog standard] log:@"isNeedGetNearbyItems: %lu - %lu <= %lu YES", [_shareList count], _currentIndex, kNeedGetNearbyCount];
		return YES;
	}

	[[FileLog standard] log:@"isNeedGetNearbyItems: %lu - %lu <= %lu NO", [_shareList count], _currentIndex, kNeedGetNearbyCount];
	return NO;
}

- (BOOL)isEnd {
    return ([_shareList count] == _currentIndex);
}

- (void)addSharesWithArray:(NSArray *) shareList {
	[[FileLog standard] log:@"getNearby shareList count:%lu", [shareList count]];
	if ([shareList count] <= 0) {
		return;
	}
    if ([_shareList lastObject].placeHolder) {
        [_shareList removeLastObject];
    }
    
	for(id item in shareList){
		ShareItem *shareItem = [[ShareItem alloc] initWithDictionary:item];
		//NSLog(@"%@", shareItem);
		[_shareList addObject:shareItem];
	}
	[self saveChanges];
}

- (void)addPlaceHolder {
    if ([_shareList lastObject].placeHolder) {
        return;
    }
    
    ShareItem *placeHolderItem = [ShareItem new];
    placeHolderItem.placeHolder = YES;
    [_shareList addObject:placeHolderItem];
    [self saveChanges];
}

- (BOOL)saveChanges {
	NSString *fileName = [PathHelper shareArchivePathWithUID:[[HXUserSession share] uid]];
	if (![NSKeyedArchiver archiveRootObject:self toFile:fileName]) {
		NSLog(@"archive share list failed.");
		if ([[NSFileManager defaultManager] removeItemAtPath:fileName error:nil]) {
			NSLog(@"delete share list archive file.");
		}
		return NO;
	}

	return YES;
}

- (BOOL)checkHistoryItemsMaxCount {
    BOOL change = NO;
	NSInteger overCount = _shareList.count - kHistoryItemsMaxCount;
	if (overCount > 0) {
		for (NSInteger i = 0; i < overCount; i++) {
			[_shareList removeObjectAtIndex:0];
			_currentIndex--;
            change = YES;
		}
		
		[self saveChanges];
    }
    return change;
}

- (void)cleanUserState {
	for(ShareItem *item in _shareList){
		item.isInfected = NO;
		item.favorite = NO;
	}
}

@end
