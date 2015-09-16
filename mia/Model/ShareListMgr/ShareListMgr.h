//
//  ShareListMgr.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "ShareItem.h"

@interface ShareListMgr : NSObject

- (id)initFromArchive;
- (NSUInteger)getOnlineCount;

- (void)addSharesWithArray:(NSArray *) shareList;
- (ShareItem *)popShareItem;

- (BOOL)saveChanges;

@end
