//
//  FavoriteMgr.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

@class FavoriteItem;

@protocol FavoriteMgrDelegate

- (void)favoriteMgrDidFinishSync;
- (void)favoriteMgrDidFinishDownload;

@end

@interface FavoriteMgr : NSObject <NSCoding>

/**
 *  使用单例初始化
 *
 */
+ (id)standard;

@property (weak, nonatomic)id<FavoriteMgrDelegate> customDelegate;

- (long)favoriteCount;
- (long)cachedCount;
- (void)syncFavoriteList;
- (NSArray *)getFavoriteListFromIndex:(long)lastIndex;
- (void)removeSelectedItems;
- (BOOL)isItemCached:(FavoriteItem *)item;
- (BOOL)isItemCachedWithUrl:(NSString *)url;

@end
