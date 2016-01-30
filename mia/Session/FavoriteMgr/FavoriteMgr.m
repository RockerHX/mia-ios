//
//  FavoriteMgr.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//
//

#import "FavoriteMgr.h"
#import "WebSocketMgr.h"
#import "MiaAPIHelper.h"
#import "FavoriteItem.h"
#import "PathHelper.h"
#import "UserSession.h"
#import "AFNetworking.h"
#import "AFNHttpClient.h"
#import "NSString+IsNull.h"
#import "FileLog.h"

static const long kFavoriteRequestItemCountPerPage	= 100;

@interface FavoriteMgr()

@end

@implementation FavoriteMgr {
	NSMutableArray 				*_tempItems;
	BOOL						_isSyncing;

	dispatch_queue_t 			_downloadQueue;
	NSURLSessionDownloadTask 	*_downloadTask;
	long						_currentDownloadIndex;
}

/**
 *  使用单例初始化
 *
 */
+ (FavoriteMgr *)standard {
    static FavoriteMgr *aMgr = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        aMgr = [[self alloc] init];
    });
    return aMgr;
}

- (id)init {
	self = [super init];
	if (self) {
		[self loadData];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReachabilityStatusChange:) name:NetworkNotificationReachabilityStatusChange object:nil];
	}
	return self;
}

- (void)dealloc {
	if (_downloadTask) {
		[_downloadTask cancel];
	}

	[[NSNotificationCenter defaultCenter] removeObserver:self name:NetworkNotificationReachabilityStatusChange object:nil];
}

- (NSInteger)currentPlaying {
	if (_currentPlaying < 0 || _currentPlaying >= _dataSource.count) {
		_currentPlaying = 0;
	}

	return _currentPlaying;
}

- (long)favoriteCount {
	return [_dataSource count];
}

- (long)cachedCount {
	long count = 0;
	for (FavoriteItem *item in _dataSource) {
		if (item.isCached) {
			count++;
		}
	}
	return count;
}


- (void)syncFavoriteList {
	if (_isSyncing) {
		NSLog(@"favorite list is still syncing");
		return;
	}

	_isSyncing = YES;
	[MiaAPIHelper getFavoriteListWithStart:[NSString stringWithFormat:@"%d", 0]
									  item:kFavoriteRequestItemCountPerPage
							 completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
								 [self handleGetFavoriteListWitRet:success userInfo:userInfo];
							 } timeoutBlock:^(MiaRequestItem *requestItem) {
								 NSLog(@"GetFavoriteList timeout");
								 [self syncFinished:NO];
							 }];
}

- (NSArray *)getFavoriteListFromIndex:(long)lastIndex {
	const static long kFavoriteListItemCountPerPage = 10;
	NSMutableArray * items = [[NSMutableArray alloc] init];
	for (long i = 0; i < kFavoriteListItemCountPerPage && (i + lastIndex) < _dataSource.count; i++) {
		[items addObject:_dataSource[i + lastIndex]];
	}

	return items;
}

- (void)removeSelectedItemsWithCompleteBlock:(void (^)(BOOL isChanged, BOOL deletePlaying, NSArray *idArray))completeBlock {
	BOOL isChanged = NO;
	BOOL deletePlaying = NO;
	NSMutableArray *idArray = [[NSMutableArray alloc] init];

	NSEnumerator *enumerator = [_dataSource reverseObjectEnumerator];
	for (FavoriteItem *item in enumerator) {
		if (item.isSelected) {
			if (item.isPlaying) {
				deletePlaying = YES;
			}

			[idArray addObject:item.sID];
			isChanged = YES;

			// 如果删除的是当前正在下载的任务
			if (_downloadTask
				&& [[[[_downloadTask originalRequest] URL] absoluteString] isEqualToString:item.music.murl]) {
				[_downloadTask cancel];
			}

			[self deleteCacheFileWithUrl:item.music.murl];
			[_dataSource removeObject:item];
		}
	}

	if (isChanged) {
		[self saveData];
	}

	if (completeBlock) {
		completeBlock(isChanged, deletePlaying, idArray);
	}
}

#pragma mark - private method

- (void)syncFinished:(BOOL)isSuccess {
	if (isSuccess) {
		// 服务器获取成功才需要合并到本地
		if ([self mergeItems]) {
			[self saveData];
		}
	}

	if (_customDelegate && [_customDelegate respondsToSelector:@selector(favoriteMgrDidFinishSync)]) {
		[_customDelegate favoriteMgrDidFinishSync];
	}

	_isSyncing = NO;

	if (isSuccess) {
		[self downloadFavorite];
	}
}

- (BOOL)isItemInArray:(FavoriteItem *)item array:(NSArray *)array {
	for (FavoriteItem *it in array) {
		if ([[item fID] isEqualToString:[it fID]]) {
			return YES;
		}
	}

	return NO;
}

- (BOOL)mergeItems {
	BOOL hasDataChanged = NO;

	// 寻找删除的元素
	NSEnumerator *deleteEnumerator = [_dataSource reverseObjectEnumerator];
	for (FavoriteItem *item in deleteEnumerator) {
		if (![self isItemInArray:item array:_tempItems]) {
			[self deleteCacheFileWithUrl:item.music.murl];
			item.isCached = NO;
			[_dataSource removeObject:item];
			hasDataChanged = YES;
		}
	}

	// 新增的反序枚举，如果是新的就插入在最前面，让最新数据是在前面
	NSEnumerator *insertEnumerator = [_tempItems reverseObjectEnumerator];
	for (FavoriteItem *newItem in insertEnumerator) {
		if (![self isItemInArray:newItem array:_dataSource]) {
			[_dataSource insertObject:newItem atIndex:0];
			hasDataChanged = YES;
		}
	}

	_tempItems = nil;
	return hasDataChanged;
}

- (void)deleteCacheFileWithUrl:(NSString *)url {
	NSString *filename = [PathHelper genMusicFilenameWithUrl:url];
	NSError *error;
	[[NSFileManager defaultManager] removeItemAtPath:filename error:&error];
}

- (void)downloadFavorite {
	if (_downloadQueue) {
		[[FileLog standard] log:@"last download queue is still running."];
		return;
	}

	[[FileLog standard] log:@"start download queue"];
	_downloadQueue = dispatch_queue_create("com.miamusic.downloadfavoritequeue", NULL);

	[self downloadNextItem:_downloadQueue];
}

- (void)downloadNextItem:(dispatch_queue_t)taskQueue {
	if (!taskQueue) {
		[[FileLog standard] log:@"downloadNextItem error, taskQueue is nil"];
		return;
	}

	// 多线程下载收藏的歌曲
	dispatch_async(taskQueue, ^()
	{
		FavoriteItem *item = [self getNextDownloadItem];
		if (!item
			|| [NSString isNull:item.music.murl]
			|| ![[WebSocketMgr standard] isWifiNetwork]) {
			// 断网后也会从0重新开始查找需要下载的歌曲
			_currentDownloadIndex = 0;

			dispatch_sync(dispatch_get_main_queue(), ^{
				if (_customDelegate && [_customDelegate respondsToSelector:@selector(favoriteMgrDidFinishDownload)]) {
					[_customDelegate favoriteMgrDidFinishDownload];
				}
			});

			_downloadQueue = nil;
			return;
		}

		_downloadTask = [AFNHttpClient downloadWithURL:item.music.murl
										  savePath:[PathHelper genMusicFilenameWithUrl:item.music.murl]
									 completeBlock:^(NSURLResponse *response, NSURL *filePath, NSError *error)
		{
			[[FileLog standard] log:@"download %@, %@, error:%@", item.music.name, item.music.murl, error];
			if (nil == error) {
				[_dataSource[_currentDownloadIndex] setIsCached:YES];
				[self saveData];
			} else {
				[_dataSource[_currentDownloadIndex] setIsCached:NO];
				if (filePath) {
					NSError *fileError;
					[[NSFileManager defaultManager] removeItemAtPath:[filePath absoluteString] error:&fileError];
				}
			}

			_downloadTask = nil;
			_currentDownloadIndex++;
			[self downloadNextItem:_downloadQueue];
		}];
	});
}

- (FavoriteItem *)getNextDownloadItem {
	FavoriteItem *item = nil;
	for (; _currentDownloadIndex < _dataSource.count; _currentDownloadIndex++) {
		item = _dataSource[_currentDownloadIndex];
		if (![self isItemCached:item]) {
			return item;
		}
	}

	return nil;
}

- (BOOL)isItemCached:(FavoriteItem *)item {
	if (nil == item) {
		return NO;
	}
	if (!item.isCached) {
		return NO;
	}

	if (![self isItemCachedWithUrl:item.music.murl]) {
		item.isCached = NO;
		return NO;
	}

	return YES;
}

- (BOOL)isItemCachedWithUrl:(NSString *)url {
	if ([NSString isNull:url]) {
		return NO;
	}

	NSFileManager *fileManager = [NSFileManager defaultManager];
	if(![fileManager fileExistsAtPath:[PathHelper genMusicFilenameWithUrl:url]]) {
		return NO;
	}

	return YES;
}

#pragma mark - Notification

- (void)notificationReachabilityStatusChange:(NSNotification *)notification {
	id status = [notification userInfo][NetworkNotificationKey_Status];
	if ([status intValue] != AFNetworkReachabilityStatusReachableViaWiFi) {
		if (_downloadTask) {
			NSLog(@"cancel current download");
			[_downloadTask cancel];
		}
	}
}

- (void)handleGetFavoriteListWitRet:(BOOL)success userInfo:(NSDictionary *) userInfo {
	if (!success) {
		[self syncFinished:NO];
		return;
	}

	NSArray *items = userInfo[@"v"][@"data"];
	if (!items) {
		[self syncFinished:NO];
		return;
	}

	if (nil == _tempItems) {
		_tempItems = [[NSMutableArray alloc] init];
	}
	
	for(id item in items){
		FavoriteItem *favoriteItem = [[FavoriteItem alloc] initWithDictionary:item];
		[_tempItems addObject:favoriteItem];
	}

	if ([items count] == kFavoriteRequestItemCountPerPage) {
		[MiaAPIHelper getFavoriteListWithStart:[NSString stringWithFormat:@"%lu", (unsigned long)[_tempItems count]]
										  item:kFavoriteRequestItemCountPerPage
								 completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
									 [self handleGetFavoriteListWitRet:success userInfo:userInfo];
								 } timeoutBlock:^(MiaRequestItem *requestItem) {
									 NSLog(@"GetFavoriteList timeout");
								 }];
	} else {
		[self syncFinished:YES];
	}
}

- (void)loadData {
	_dataSource = [NSKeyedUnarchiver unarchiveObjectWithFile:[PathHelper favoriteArchivePathWithUID:[[UserSession standard] uid]]];
	if (!_dataSource) {
		_dataSource = [[NSMutableArray alloc] init];
	}
}

- (BOOL)saveData {
	NSString *fileName = [PathHelper favoriteArchivePathWithUID:[[UserSession standard] uid]];
	if (![NSKeyedArchiver archiveRootObject:_dataSource toFile:fileName]) {
		NSLog(@"archive share list failed.");
		if ([[NSFileManager defaultManager] removeItemAtPath:fileName error:nil]) {
			NSLog(@"delete share list archive file.");
		}
		return NO;
	}

	return YES;
}

//将对象编码(即:序列化)
- (void) encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:_dataSource forKey:@"favoriteItems"];
}

//将对象解码(反序列化)
-(id) initWithCoder:(NSCoder *)aDecoder {
	if (self=[super init]) {
		_dataSource = [aDecoder decodeObjectForKey:@"favoriteItems"];
	}

	return (self);
	
}

@end
