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

static const long kFavoriteRequestItemCountPerPage	= 100;

@interface FavoriteMgr()

@end

@implementation FavoriteMgr {
	NSMutableArray *_dataSource;
	long			_lastID;
	long			_latestID;
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
		_dataSource = [[NSMutableArray alloc] init];
		_lastID = 0;
		_latestID = 0;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidReceiveMessage:) name:WebSocketMgrNotificationDidReceiveMessage object:nil];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidReceiveMessage object:nil];
}

- (long)favoriteCount {
	// TODO linyehui fav
	return [_dataSource count];
}

- (long)cachedCount {
	// TODO linyehui fav
	return 0;
}


- (void)syncFavoriteList {
	// TODO linyehui fav
	// 跟服务器进行同步，这里的同步需要处理：新增，删除，修改等操作
	[MiaAPIHelper getFavoriteListWithStart:[NSString stringWithFormat:@"%ld", _lastID] item:kFavoriteRequestItemCountPerPage];
}

- (void)syncFinished {
	if (_customDelegate) {
		[_customDelegate favoriteMgrDidFinishSync];
	}
}

- (NSArray *)getFavoriteListFromIndex:(long)lastIndex {
	const static long kFavoriteListItemCountPerPage = 10;
	NSMutableArray * items = [[NSMutableArray alloc] init];
	for (long i = 0; i < kFavoriteListItemCountPerPage && (i + lastIndex) < _dataSource.count; i++) {
		[items addObject:_dataSource[i + lastIndex]];
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

	for(id item in items){
		FavoriteItem *favoriteItem = [[FavoriteItem alloc] initWithDictionary:item];
		[_dataSource addObject:favoriteItem];
	}

	if ([items count] == kFavoriteRequestItemCountPerPage) {
		[MiaAPIHelper getFavoriteListWithStart:[NSString stringWithFormat:@"%ld", _lastID] item:kFavoriteRequestItemCountPerPage];
	} else {
		[self syncFinished];
	}
}

@end
