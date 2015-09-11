//
//  ViewController.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "RadioViewController.h"
#import "WebSocketMgr.h"
#import "RadioView.h"
#import "UIImage+ColorToImage.h"

@interface RadioViewController () <RadioViewDelegate>

@end

@implementation RadioViewController {
//	SRWebSocket *_webSocket;
	RadioView *radioView;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	self.view.backgroundColor = [UIColor whiteColor];
	self.view.userInteractionEnabled = YES;

	[self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
	if ([[UIView appearance] respondsToSelector:@selector(setTintColor:)]) {
		[self.navigationController.navigationBar setTintColor:UIColorFromHex(@"#FFFFFF", 1.0)];
	}else{
		[self.navigationController.navigationBar setBackgroundImage:[UIImage createImageWithColor:UIColorFromHex(@"#FFFFFF", 1.0)] forBarMetrics:UIBarMetricsDefault];
	}
	self.navigationController.navigationBar.translucent = NO;

	NSDictionary *fontDictionary = @{NSForegroundColorAttributeName:UIColorFromHex(@"#434343", 1.0),
									 NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Regular" size:19.0]};
	[self.navigationController.navigationBar setTitleTextAttributes:fontDictionary];
	self.navigationItem.title = self.title;

	CGRect radioFrame = CGRectMake(self.view.bounds.origin.x,
									 self.view.bounds.origin.y,
									 self.view.bounds.size.width,
									 self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height - self.navigationController.navigationBar.frame.origin.y);
	radioView = [[RadioView alloc] initWithFrame:radioFrame];
	radioView.radioViewDelegate = self;
	[self.view addSubview:radioView];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidOpen:) name:WebSocketMgrNotificationDidOpen object:[WebSocketMgr standarWebSocketMgr]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidFailWithError:) name:WebSocketMgrNotificationDidFailWithError object:[WebSocketMgr standarWebSocketMgr]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidReceiveMessage:) name:WebSocketMgrNotificationDidReceiveMessage object:[WebSocketMgr standarWebSocketMgr]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidCloseWithCode:) name:WebSocketMgrNotificationDidCloseWithCode object:[WebSocketMgr standarWebSocketMgr]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidReceivePong:) name:WebSocketMgrNotificationDidReceivePong object:[WebSocketMgr standarWebSocketMgr]];
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidOpen object:[WebSocketMgr standarWebSocketMgr]];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidFailWithError object:[WebSocketMgr standarWebSocketMgr]];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidReceiveMessage object:[WebSocketMgr standarWebSocketMgr]];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidCloseWithCode object:[WebSocketMgr standarWebSocketMgr]];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidReceivePong object:[WebSocketMgr standarWebSocketMgr]];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[WebSocketMgr standarWebSocketMgr] reconnect];
	self.title = @"Opening Connection...";
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)sendPing:(id)sender;
{
	[[WebSocketMgr standarWebSocketMgr] sendPing:nil];
}

- (void)viewDidAppear:(BOOL)animated;
{
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];

	[[WebSocketMgr standarWebSocketMgr] close];
}

#pragma mark - Notification

-(void)notificationWebSocketDidOpen:(NSNotification *)notification {
	self.title = @"Connected!";
}
-(void)notificationWebSocketDidFailWithError:(NSNotification *)notification {
	self.title = @"Connection Failed! (see logs)";
}
-(void)notificationWebSocketDidReceiveMessage:(NSNotification *)notification {
	NSLog(@"RadioViewController Received \"%@\"", [[notification userInfo] valueForKey:WebSocketMgrNotificationUserInfoKey]);
}
-(void)notificationWebSocketDidCloseWithCode:(NSNotification *)notification {
	self.title = @"Connection Closed! (see logs)";
}
-(void)notificationWebSocketDidReceivePong:(NSNotification *)notification {
	NSLog(@"RadioViewController Websocket received pong");
}

#pragma mark - RadioViewDelegate

- (void)notifyPing {
	[self sendPing:nil];
}

- (void)notifyLogin {
	NSString *testLoginData = @"{\"c\":\"User.Post.Login\",\"r\":\"1\",\"s\":\"123456789\",\"v\":{\"phone\":\"13267189403\",\"pwd\":\"e10adc3949ba59abbe56e057f20f883e\",\"imei\":\"1223333\",\"dev\":\"1\"}}";
	[[WebSocketMgr standarWebSocketMgr] send:testLoginData];
}

- (void)notifyReconnect {
	[[WebSocketMgr standarWebSocketMgr] reconnect];
	self.title = @"Opening Connection...";
}

@end
