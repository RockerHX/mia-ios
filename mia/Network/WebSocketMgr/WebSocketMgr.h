//
//  WebSocketMgr.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

//typedef void(^RequestGetBannerSceneSuccess)();

@interface WebSocketMgr : NSObject

/**
 *  使用单例初始化
 *
 */
+(id)standarWebSocketMgr;

- (void)reconnect;
- (void)close;
- (void)sendPing:(id)sender;
- (void)send:(id)data;

@end
