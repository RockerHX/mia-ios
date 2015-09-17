//
//  WebSocketMgr.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

//typedef void(^RequestGetBannerSceneSuccess)();

extern NSString * const WebSocketMgrNotificationKey_Msg;
extern NSString * const WebSocketMgrNotificationKey_Command;
extern NSString * const WebSocketMgrNotificationKey_Values;

extern NSString * const WebSocketMgrNotificationDidOpen;
extern NSString * const WebSocketMgrNotificationDidFailWithError;
extern NSString * const WebSocketMgrNotificationDidReceiveMessage;
extern NSString * const WebSocketMgrNotificationDidCloseWithCode;
extern NSString * const WebSocketMgrNotificationDidReceivePong;

@interface WebSocketMgr : NSObject

/**
 *  使用单例初始化
 *
 */
+(id)standard;

- (void)reconnect;
- (void)close;
- (void)sendPing:(id)sender;
- (void)send:(id)data;

@end
