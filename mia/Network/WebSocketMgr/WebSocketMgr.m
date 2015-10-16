//
//  WebSocketMgr.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//
//

#import "WebSocketMgr.h"
#import "SRWebSocket.h"
#import "MiaAPIHelper.h"
#import "AFNetworking.h"

NSString * const WebSocketMgrNotificationKey_Msg				= @"msg";
NSString * const WebSocketMgrNotificationKey_Command			= @"cmd";
NSString * const WebSocketMgrNotificationKey_Values				= @"values";

NSString * const WebSocketMgrNotificationDidOpen			 	= @"WebSocketMgrNotificationDidOpen";
NSString * const WebSocketMgrNotificationDidFailWithError		= @"WebSocketMgrNotificationDidFailWithError";
NSString * const WebSocketMgrNotificationDidReceiveMessage		= @"WebSocketMgrNotificationDidReceiveMessage";
NSString * const WebSocketMgrNotificationDidCloseWithCode		= @"WebSocketMgrNotificationDidCloseWithCode";
NSString * const WebSocketMgrNotificationDidReceivePong			= @"WebSocketMgrNotificationDidReceivePong";

NSString * const NetworkNotificationKey_Status					= @"status";
NSString * const NetworkNotificationReachabilityStatusChange	= @"NetworkNotificationReachabilityStatusChange";

@interface WebSocketMgr() <SRWebSocketDelegate>

@end

@implementation WebSocketMgr{
	SRWebSocket 				*_webSocket;
	NSTimer 					*_timer;
	AFNetworkReachabilityStatus _networkStatus;
}

/**
 *  使用单例初始化
 *
 */
+ (id)standard{
    static WebSocketMgr *webSocketMgr = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        webSocketMgr = [[self alloc] init];
    });
    return webSocketMgr;
}

- (void)watchNetworkStatus {
	_networkStatus = AFNetworkReachabilityStatusUnknown;
	
	[[AFNetworkReachabilityManager sharedManager] startMonitoring];
	[[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:
	 ^(AFNetworkReachabilityStatus status) {
		NSLog(@"Network status change: %ld", status);
		_networkStatus = status;

		 NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								   [NSNumber numberWithInteger:status], NetworkNotificationKey_Status,
								   nil];
		 [[NSNotificationCenter defaultCenter] postNotificationName:NetworkNotificationReachabilityStatusChange object:self userInfo:userInfo];
	}];
}

- (BOOL)isNetworkEnable {
	if (_networkStatus == AFNetworkReachabilityStatusReachableViaWWAN
		|| _networkStatus == AFNetworkReachabilityStatusReachableViaWiFi) {
		return YES;
	}

	return NO;
}

- (BOOL)isWifiNetwork {
	return (_networkStatus == AFNetworkReachabilityStatusReachableViaWiFi);
}

- (BOOL)isOpen {
	if ([_webSocket readyState] == SR_OPEN) {
		return YES;
	}

	return NO;
}

- (BOOL)isClosed {
	if (!_webSocket)
		return YES;

	if ([_webSocket readyState] == SR_CLOSED) {
		return YES;
	}

	return NO;
}

- (void)reconnect {
	_webSocket.delegate = nil;
	[_webSocket close];

#ifdef DEBUG
	static NSString *kMIAAPIUrl = @"ws://api.miamusic.com:80";
#else
	static NSString *kMIAAPIUrl = @"ws://ws.miamusic.com:80";
#endif

	_webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kMIAAPIUrl]]];
	_webSocket.delegate = self;

	NSLog(@"WebSocket opening");
	[_webSocket open];
	
}

- (void)close {
	NSLog(@"WebSocket closing");
	[_timer invalidate];

	_webSocket.delegate = nil;
	[_webSocket close];
	_webSocket = nil;
}

- (void)sendPing:(id)sender {
	if (![self isOpen]) {
		NSLog(@"sendPing failed, websocket is not opening!");
		return;
	}

	[_webSocket sendPing:nil];
}

- (void)send:(id)data {
	if (![self isOpen]) {
		NSLog(@"send failed, websocket is not opening!");
		return;
	}

	[_webSocket send:data];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
	// 心跳的定时发送时间间隔
	static const NSTimeInterval kWebSocketPingTimeInterval = 30;

	NSLog(@"Websocket Connected");
	_timer = [NSTimer scheduledTimerWithTimeInterval:kWebSocketPingTimeInterval
											 target:self
										   selector:@selector(pingTimerAction)
										   userInfo:nil
											repeats:YES];
	//self.title = @"Connected!";
	[[NSNotificationCenter defaultCenter] postNotificationName:WebSocketMgrNotificationDidOpen object:self];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
	NSLog(@":( Websocket Failed With Error %@", error);

	//self.title = @"Connection Failed! (see logs)";
	[_timer invalidate];
	_webSocket = nil;

	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:WebSocketMgrNotificationKey_Msg];
	[[NSNotificationCenter defaultCenter] postNotificationName:WebSocketMgrNotificationDidFailWithError object:self userInfo:userInfo];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
	NSLog(@"Received \"%@\"", message);

	//解析JSON
	NSError *error = nil;
	id resultString = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding]
													  options:NSJSONReadingMutableLeaves
														error:&error];
	if (error) {
		NSLog(@"dic->%@",error);
		return;
	}

	[[NSNotificationCenter defaultCenter] postNotificationName:WebSocketMgrNotificationDidReceiveMessage object:self userInfo:resultString];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
	NSLog(@"WebSocket closed");
	//self.title = @"Connection Closed! (see logs)";
	[_timer invalidate];
	_webSocket = nil;

	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInteger:code], @"code",
							  reason, @"reason",
							  [NSNumber numberWithInteger:wasClean], @"wasClean",
							  nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:WebSocketMgrNotificationDidOpen object:self userInfo:userInfo];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
	NSLog(@"Websocket received pong");
	[[NSNotificationCenter defaultCenter] postNotificationName:WebSocketMgrNotificationDidReceivePong object:self];
}

# pragma mark - Timer Action
-(void)pingTimerAction {
	[_webSocket sendPing:nil];
}

@end
















