//
//  FavoriteMgr.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FavoriteItem.h"

@protocol FavoriteMgrDelegate <NSObject>

@optional
- (void)favoriteMgrDidFinishSync;
- (void)favoriteMgrDidFinishDownload;

@end

@interface FavoriteMgr : NSObject <NSCoding>

/**
 *  使用单例初始化
 *
 */
+ (FavoriteMgr *)standard;

@property (weak, nonatomic)id<FavoriteMgrDelegate> customDelegate;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) NSInteger currentPlaying;

- (long)favoriteCount;
- (long)cachedCount;
- (void)syncFavoriteList;
- (NSArray *)getFavoriteListFromIndex:(long)lastIndex;
- (void)removeSelectedItemsWithCompleteBlock:(void (^)(BOOL isChanged, BOOL deletePlaying, NSArray *idArray))completeBlock;
- (void)removeSelectedItem:(FavoriteItem *)item;
- (BOOL)isItemCached:(FavoriteItem *)item;
- (BOOL)isItemCachedWithUrl:(NSString *)url;

@end
