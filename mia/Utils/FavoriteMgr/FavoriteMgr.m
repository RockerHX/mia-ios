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
#import "NSString+MD5.h"
#import "NSString+IsNull.h"

static const long kFavoriteRequestItemCountPerPage	= 100;

@interface FavoriteMgr()

@end

@implementation FavoriteMgr {
	NSMutableArray 				*_favoriteItems;
	NSMutableArray 				*_tempItems;
	BOOL						_isSyncing;

	NSURLSessionDownloadTask 	*_downloadTask;
	long						_currentDownloadIndex;
}

/**
 *  使用单例初始化
 *
 */
+(id)standard{
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
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidReceiveMessage:) name:WebSocketMgrNotificationDidReceiveMessage object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReachabilityStatusChange:) name:NetworkNotificationReachabilityStatusChange object:nil];
	}
	return self;
}

- (void)dealloc {
	if (_downloadTask) {
		[_downloadTask cancel];
	}

	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidReceiveMessage object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NetworkNotificationReachabilityStatusChange object:nil];
}

- (long)favoriteCount {
	// TODO linyehui fav
	return [_favoriteItems count];
}

- (long)cachedCount {
	// TODO linyehui fav
	return 0;
}


- (void)syncFavoriteList {
	if (_isSyncing) {
		NSLog(@"favorite list is still syncing");
		return;
	}

	_isSyncing = YES;

	// TODO linyehui fav
	// 跟服务器进行同步，这里的同步需要处理：新增，删除，修改等操作
	[MiaAPIHelper getFavoriteListWithStart:[NSString stringWithFormat:@"%d", 0] item:kFavoriteRequestItemCountPerPage];
}

- (void)syncFinished {
	[self mergeItems];
	[self saveData];

	if (_customDelegate) {
		[_customDelegate favoriteMgrDidFinishSync];
	}

	_isSyncing = NO;

	[self downloadFavorite];
}

- (BOOL)isItemInArray:(FavoriteItem *)item array:(NSArray *)array {
	for (FavoriteItem *it in array) {
		if ([[item fID] isEqualToString:[it fID]]) {
			return YES;
		}
	}

	return NO;
}

- (void)mergeItems {
	// TODO linyehui fav
	// 合并，找到新增和删除的，对文件进行操作，修改的暂定不做改动

	// 寻找删除的元素
	NSEnumerator *enumerator = [_favoriteItems reverseObjectEnumerator];
	for (FavoriteItem *item in enumerator) {
		if (![self isItemInArray:item array:_tempItems]) {
			[_favoriteItems removeObject:item];
		}
	}

	for (FavoriteItem *newItem in _tempItems) {
		if (![self isItemInArray:newItem array:_favoriteItems]) {
			// TODO linyehui fav
			// 插入时的排序
			[_favoriteItems addObject:newItem];
		}
	}

	_tempItems = nil;
}

- (void)downloadFavorite {
	// TODO linyehui fav
	// 多线程下载收藏的歌曲
	dispatch_queue_t queue = dispatch_queue_create("DownloadFavoriteQueue", NULL);
	dispatch_async(queue, ^() {
		FavoriteItem *item = [self getNextDownloadItem];
		if (!item
			|| [NSString isNull:item.music.murl]
			|| ![[WebSocketMgr standard] isWifiNetwork]) {
			// 断网后也会从0重新开始查找需要下载的歌曲
			_currentDownloadIndex = 0;
			return;
		}

		_downloadTask = [AFNHttpClient downloadWithURL:item.music.murl
											  savePath:[self genMusicFilenameWithUrl:item.music.murl]
										 completeBlock:
						 ^(NSURLResponse *response, NSURL *filePath, NSError *error) {
							 if (nil == error) {
								 [_favoriteItems[_currentDownloadIndex] setIsCached:YES];
								 [self saveData];
							 }

							 _downloadTask = nil;
							 _currentDownloadIndex++;
							 [self downloadFavorite];
						 }];
	});
}

- (FavoriteItem *)getNextDownloadItem {
	FavoriteItem *item = nil;
	for (; _currentDownloadIndex < _favoriteItems.count; _currentDownloadIndex++) {
		item = _favoriteItems[_currentDownloadIndex];
		if (item && !item.isCached) {
			return item;
		}
	}

	return nil;
}

- (NSString *)genMusicFilenameWithUrl:(NSString *)url {
	return [NSString stringWithFormat:@"%@/%@", [PathHelper favoriteCacheDir], [NSString md5HexDigest:url]];
}

- (NSArray *)getFavoriteListFromIndex:(long)lastIndex {
	const static long kFavoriteListItemCountPerPage = 10;
	NSMutableArray * items = [[NSMutableArray alloc] init];
	for (long i = 0; i < kFavoriteListItemCountPerPage && (i + lastIndex) < _favoriteItems.count; i++) {
		[items addObject:_favoriteItems[i + lastIndex]];
	}

	return items;
}

#pragma mark - Notification

- (void)notificationWebSocketDidReceiveMessage:(NSNotification *)notification {
	NSString *command = [notification userInfo][MiaAPIKey_ServerCommand];
	id ret = [notification userInfo][MiaAPIKey_Values][MiaAPIKey_Return];
	//NSLog(@"%@", command);

	if ([command isEqualToString:MiaAPICommand_User_GetStart]) {
		[self handleGetFavoriteListWitRet:[ret intValue] userInfo:[notification userInfo]];
	}
}

- (void)notificationReachabilityStatusChange:(NSNotification *)notification {
	id status = [notification userInfo][NetworkNotificationKey_Status];
	if ([status intValue] != AFNetworkReachabilityStatusReachableViaWiFi) {
		if (_downloadTask) {
			NSLog(@"cancel current download");
			[_downloadTask cancel];
		}
	}
}

- (void)handleGetFavoriteListWitRet:(int)ret userInfo:(NSDictionary *) userInfo {
	if (ret != 0) {
		[self syncFinished];
		return;
	}

	NSArray *items = userInfo[@"v"][@"data"];
	if (!items) {
		[self syncFinished];
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
		[MiaAPIHelper getFavoriteListWithStart:[NSString stringWithFormat:@"%ld", [_tempItems count]] item:kFavoriteRequestItemCountPerPage];
	} else {
		[self syncFinished];
	}
}

- (void)loadData {
	_favoriteItems = [NSKeyedUnarchiver unarchiveObjectWithFile:[PathHelper favoriteArchivePathWithUID:[[UserSession standard] uid]]];
	if (!_favoriteItems) {
		_favoriteItems = [[NSMutableArray alloc] init];
	}
}

- (BOOL)saveData {
	NSString *fileName = [PathHelper favoriteArchivePathWithUID:[[UserSession standard] uid]];
	if (![NSKeyedArchiver archiveRootObject:_favoriteItems toFile:fileName]) {
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
	[aCoder encodeObject:_favoriteItems forKey:@"favoriteItems"];
}

//将对象解码(反序列化)
-(id) initWithCoder:(NSCoder *)aDecoder {
	if (self=[super init]) {
		_favoriteItems = [aDecoder decodeObjectForKey:@"favoriteItems"];
	}

	return (self);
	
}

@end
