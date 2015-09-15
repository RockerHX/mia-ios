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
#import "MiaAPIHelper.h"
#import "AAPullToRefresh.h"

const CGFloat kTopViewDefaultHeight				= 30.0f;
const CGFloat kBottomViewDefaultHeight			= 30.0f;

@interface RadioViewController () <RadioViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) RadioView *radioView;

@end

@implementation RadioViewController {
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.view.backgroundColor = [UIColor whiteColor];

	self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
	self.scrollView.delegate = self;
	self.scrollView.maximumZoomScale = 2.0f;
	self.scrollView.contentSize = self.view.bounds.size;
	self.scrollView.alwaysBounceHorizontal = NO;
	self.scrollView.alwaysBounceVertical = YES;
	self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.scrollView.backgroundColor = UIColor.grayColor;
	[self.view addSubview:self.scrollView];

	CGRect rect = self.scrollView.bounds;
	rect.size.height = self.scrollView.contentSize.height;
	rect.origin.y += kTopViewDefaultHeight;
	rect.size.height -= (kTopViewDefaultHeight + kBottomViewDefaultHeight);

	self.radioView = [[RadioView alloc] initWithFrame:rect];
	self.radioView.radioViewDelegate = self;
	//self.thresholdView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	//self.radioView.userInteractionEnabled = NO;
	self.radioView.backgroundColor = UIColor.whiteColor;
	[self.scrollView addSubview:self.radioView];

	// top
	AAPullToRefresh *tv = [self.scrollView addPullToRefreshPosition:AAPullToRefreshPositionTop actionHandler:^(AAPullToRefresh *v){
		NSLog(@"fire from top");
		[v performSelector:@selector(stopIndicatorAnimation) withObject:nil afterDelay:1.0f];
	}];
	tv.imageIcon = [UIImage imageNamed:@"launchpad"];
	tv.borderColor = [UIColor whiteColor];

	// bottom
	AAPullToRefresh *bv = [self.scrollView addPullToRefreshPosition:AAPullToRefreshPositionBottom actionHandler:^(AAPullToRefresh *v){
		NSLog(@"fire from bottom");
		[v performSelector:@selector(stopIndicatorAnimation) withObject:nil afterDelay:1.0f];
	}];
	bv.imageIcon = [UIImage imageNamed:@"launchpad"];
	bv.borderColor = [UIColor whiteColor];

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

- (void)viewWillLayoutSubviews
{
	CGRect rect = self.scrollView.bounds;
	rect.size.height = self.scrollView.contentSize.height;
	rect.origin.y += kTopViewDefaultHeight;
	rect.size.height -= (kTopViewDefaultHeight + kBottomViewDefaultHeight);
	self.radioView.frame = rect;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return self.radioView;
}

- (void)sendPing:(id)sender;
{
	[[WebSocketMgr standarWebSocketMgr] sendPing:nil];
}

- (void)viewDidAppear:(BOOL)animated;
{
	//[self.navigationController setNavigationBarHidden:YES animated:animated];
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[[WebSocketMgr standarWebSocketMgr] close];
	//[self.navigationController setNavigationBarHidden:NO animated:animated];
	[super viewDidDisappear:animated];
}

- (void)loadData {
	[MiaAPIHelper getNearbyWithLatitude:-22 longitude:33 start:1 item:1];
}

#pragma mark - Notification

-(void)notificationWebSocketDidOpen:(NSNotification *)notification {
	self.title = @"Connected!";
	[_radioView setLogText:@"Websocket Connected"];

	// TODO send uuid to server
	[MiaAPIHelper sendUUID];
	[self loadData];

}
-(void)notificationWebSocketDidFailWithError:(NSNotification *)notification {
	self.title = @"Connection Failed! (see logs)";
	[_radioView setLogText:@"Websocket Connection Failed."];
}
-(void)notificationWebSocketDidReceiveMessage:(NSNotification *)notification {
	NSString *msg = [[NSString alloc] initWithFormat:@"%@", [[notification userInfo] valueForKey:WebSocketMgrNotificationUserInfoKey]];
	//NSLog(@"RadioViewController Received \"%@\"", msg);
	[_radioView setLogText:msg];

	//解析JSON
	NSError *error = nil;
	id resultString = [NSJSONSerialization JSONObjectWithData:[msg dataUsingEncoding:NSUTF8StringEncoding]
													  options:NSJSONReadingMutableLeaves
														error:&error];
	if (error) {
		NSLog(@"dic->%@",error);
		return;
	}

	NSString *command = resultString[MiaAPIKey_ServerCommand];
	NSLog(@"%@", command);
	
	//NSArray *navigatorArray = resultString[@"navigator"];

	//NSLog(@"\njsonString:%@\nresultString:%@\nnavigatorArray:%@", jsonString, resultString, navigatorArray);
}

-(void)notificationWebSocketDidCloseWithCode:(NSNotification *)notification {
	self.title = @"Connection Closed! (see logs)";
}
-(void)notificationWebSocketDidReceivePong:(NSNotification *)notification {
//	NSLog(@"RadioViewController Websocket received pong");
	[_radioView setLogText:@"Websocket received pong"];
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
