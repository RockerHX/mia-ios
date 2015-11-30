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
+ (FavoriteMgr *)standard;

@property (weak, nonatomic)               id  <FavoriteMgrDelegate>delegate;
@property (nonatomic, assign)      NSInteger  playingIndex;
@property (nonatomic, strong) NSMutableArray<FavoriteItem *> *dataSource;

- (NSInteger)favoriteCount;
- (NSInteger)cachedCount;
- (void)syncFavoriteList;
- (NSArray *)getFavoriteListFromIndex:(NSInteger)lastIndex;
- (void)removeSelectedItemsWithCompleteBlock:(void (^)(BOOL isChanged, BOOL deletePlaying, NSArray *idArray))completeBlock;
- (BOOL)isItemCached:(FavoriteItem *)item;
- (BOOL)isItemCachedWithUrl:(NSString *)url;

@end
