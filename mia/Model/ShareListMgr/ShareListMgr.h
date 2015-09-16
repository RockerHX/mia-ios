//
//  ShareListMgr.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "ShareItem.h"

@interface ShareListMgr : NSObject <NSCoding>

@property (strong, nonatomic) NSMutableArray *onlineList;
@property (strong, nonatomic) NSMutableArray *offlineList;
@property (strong, nonatomic) ShareItem *currentShareItem;

+ (id)initFromArchive;
- (NSUInteger)getOnlineCount;

- (void)addSharesWithArray:(NSArray *) shareList;
- (ShareItem *)popShareItem;

- (BOOL)saveChanges;

@end
