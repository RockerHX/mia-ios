//
//  ShareListMgr.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "ShareItem.h"

@interface ShareListMgr : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSArray<ShareItem *> *shareList;

@property (nonatomic, assign) NSInteger currentIndex;

+ (instancetype)initFromArchive;

// 游标向左移动
- (BOOL)cursorShiftLeft;
// 游标向右移动
- (BOOL)cursorShiftRight;

- (BOOL)isNeedGetNearbyItems;
- (BOOL)isEnd;

- (void)addSharesWithArray:(NSArray *)shareList;
- (BOOL)checkHistoryItemsMaxCount;

- (void)cleanUserState;

@end
