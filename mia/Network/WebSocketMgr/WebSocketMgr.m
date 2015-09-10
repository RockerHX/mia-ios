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

NSString * const WebSocketMgrNotificationUserInfoKey			= @"msg";

NSString * const WebSocketMgrNotificationDidOpen			 	= @"WebSocketMgrNotificationDidOpen";
NSString * const WebSocketMgrNotificationDidFailWithError		= @"WebSocketMgrNotificationDidFailWithError";
NSString * const WebSocketMgrNotificationDidReceiveMessage		= @"WebSocketMgrNotificationDidReceiveMessage";
NSString * const WebSocketMgrNotificationDidCloseWithCode		= @"WebSocketMgrNotificationDidCloseWithCode";
NSString * const WebSocketMgrNotificationDidReceivePong			= @"WebSocketMgrNotificationDidReceivePong";

@interface WebSocketMgr() <SRWebSocketDelegate>

@end

@implementation WebSocketMgr{
	SRWebSocket *_webSocket;
	NSTimer *timer;
}

/**
 *  使用单例初始化
 *
 */
+(id)standarWebSocketMgr{
    static WebSocketMgr *webSocketMgr = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        webSocketMgr = [[self alloc] init];
    });
    return webSocketMgr;
}

- (void)reconnect
{
	_webSocket.delegate = nil;
	[_webSocket close];

	_webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://api.miamusic.com"]]];
	_webSocket.delegate = self;

	//self.title = @"Opening Connection...";
	NSLog(@"WebSocket opening");
	[_webSocket open];
	
}

- (void)close
{
	[timer invalidate];

	_webSocket.delegate = nil;
	[_webSocket close];
	_webSocket = nil;
}

- (void)sendPing:(id)sender
{
	[_webSocket sendPing:nil];
}

- (void)send:(id)data {
	[_webSocket send:data];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
	// 心跳的定时发送时间间隔
	static const NSTimeInterval kWebSocketPingTimeInterval = 30;

	NSLog(@"Websocket Connected");
	timer = [NSTimer scheduledTimerWithTimeInterval:kWebSocketPingTimeInterval
											 target:self
										   selector:@selector(pingTimerAction)
										   userInfo:nil
											repeats:YES];
	//self.title = @"Connected!";
	[[NSNotificationCenter defaultCenter] postNotificationName:WebSocketMgrNotificationDidOpen object:self];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
	NSLog(@":( Websocket Failed With Error %@", error);

	//self.title = @"Connection Failed! (see logs)";
	[timer invalidate];
	_webSocket = nil;

	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:WebSocketMgrNotificationUserInfoKey];
	[[NSNotificationCenter defaultCenter] postNotificationName:WebSocketMgrNotificationDidFailWithError object:self userInfo:userInfo];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
	NSLog(@"Received \"%@\"", message);
	//[_messages addObject:[[TCMessage alloc] initWithMessage:message fromMe:NO]];
	//[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_messages.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
	//[self.tableView scrollRectToVisible:self.tableView.tableFooterView.frame animated:YES];

	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:WebSocketMgrNotificationUserInfoKey];
	[[NSNotificationCenter defaultCenter] postNotificationName:WebSocketMgrNotificationDidReceiveMessage object:self userInfo:userInfo];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
	NSLog(@"WebSocket closed");
	//self.title = @"Connection Closed! (see logs)";
	[timer invalidate];
	_webSocket = nil;

	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInteger:code],@"code",
							  reason,@"reason",
							  [NSNumber numberWithInteger:wasClean],@"wasClean",
							  nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:WebSocketMgrNotificationDidOpen object:self userInfo:userInfo];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;
{
	NSLog(@"Websocket received pong");
	[[NSNotificationCenter defaultCenter] postNotificationName:WebSocketMgrNotificationDidReceivePong object:self];
}

# pragma mark - Timer Action
-(void)pingTimerAction {
	[_webSocket sendPing:nil];
}

@end
















