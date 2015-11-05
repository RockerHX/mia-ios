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
@property (assign, nonatomic) NSInteger currentIndex;

+ (instancetype)initFromArchive;

- (BOOL)isNeedGetNearbyItems;
- (BOOL)isEnd;

- (void)addSharesWithArray:(NSArray *)shareList;
- (BOOL)checkHistoryItemsMaxCount;

//- (BOOL)saveChanges;

@end
