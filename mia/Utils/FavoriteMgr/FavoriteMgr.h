//
//  FavoriteMgr.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

@interface FavoriteMgr : NSObject

/**
 *  使用单例初始化
 *
 */
+ (id)standard;

- (long)favoriteCount;
- (long)cachedCount;

@end
