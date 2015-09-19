//
//  ShareListMgr.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "ShareItem.h"

@interface ShareListMgr : NSObject <NSCoding>

@property (strong, nonatomic) NSMutableArray *shareList;
@property (assign, nonatomic) NSInteger currentItem;
//@property (strong, nonatomic) ShareItem *currentShareItem;

+ (id)initFromArchive;
- (NSUInteger)getUnreadCount;

- (BOOL)isNeedGetNearbyItems;
- (ShareItem *)getCurrentItem;
- (ShareItem *)getLeftItem;
- (ShareItem *)getRightItem;

// 游标向左移动
- (BOOL)cursorShiftLeft;
// 游标向右移动
- (BOOL)cursorShiftRight;

- (void)addSharesWithArray:(NSArray *) shareList;
- (void)checkHistoryItemsMaxCount;

//- (BOOL)saveChanges;

@end
