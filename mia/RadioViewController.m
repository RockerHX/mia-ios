//
//  ViewController.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "RadioViewController.h"
#import "SRWebSocket.h"
#import "RadioView.h"
#import "UIImage+ColorToImage.h"

@interface RadioViewController () <SRWebSocketDelegate, RadioViewDelegate>

@end

@implementation RadioViewController {
	SRWebSocket *_webSocket;
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
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)_reconnect;
{
	_webSocket.delegate = nil;
	[_webSocket close];

	_webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://api.miamusic.com"]]];
	_webSocket.delegate = self;

	self.title = @"Opening Connection...";
	[_webSocket open];

}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self _reconnect];
}

- (void)reconnect:(id)sender;
{
	[self _reconnect];
}

- (void)sendPing:(id)sender;
{
	[_webSocket sendPing:nil];
}

- (void)viewDidAppear:(BOOL)animated;
{
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];

	_webSocket.delegate = nil;
	[_webSocket close];
	_webSocket = nil;
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
	NSLog(@"Websocket Connected");
	self.title = @"Connected!";
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
	NSLog(@":( Websocket Failed With Error %@", error);

	self.title = @"Connection Failed! (see logs)";
	_webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
	NSLog(@"Received \"%@\"", message);
	//[_messages addObject:[[TCMessage alloc] initWithMessage:message fromMe:NO]];
	//[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_messages.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
	//[self.tableView scrollRectToVisible:self.tableView.tableFooterView.frame animated:YES];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
	NSLog(@"WebSocket closed");
	self.title = @"Connection Closed! (see logs)";
	_webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;
{
	NSLog(@"Websocket received pong");
}


#pragma mark - RadioViewDelegate

- (void)notifyPing {
	[self sendPing:nil];
}

- (void)notifyLogin {
	[_webSocket send:@"{\"c\":\"User.Post.Login\",\"r\":\"1\",\"s\":\"123456789\",\"v\":{\"phone\":\"13267189403\",\"pwd\":\"e10adc3949ba59abbe56e057f20f883e\",\"imei\":\"1223333\",\"dev\":\"1\"}}"];
}

@end
