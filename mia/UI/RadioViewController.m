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
#import "UIImage+Extrude.h"
#import "MiaAPIHelper.h"
#import "AAPullToRefresh.h"
#import "ShareListMgr.h"
#import "HJWButton.h"

const CGFloat kTopViewDefaultHeight				= 30.0f;
const CGFloat kBottomViewDefaultHeight			= 30.0f;

@interface RadioViewController () <RadioViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) RadioView *radioView;

@end

@implementation RadioViewController {
	ShareListMgr *shareListMgr;
	BOOL isLoading;
	HJWButton *profileButton;
	HJWButton *shareButton;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self initUI];

	shareListMgr = [ShareListMgr initFromArchive];
	
	isLoading = YES;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidOpen:) name:WebSocketMgrNotificationDidOpen object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidFailWithError:) name:WebSocketMgrNotificationDidFailWithError object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidReceiveMessage:) name:WebSocketMgrNotificationDidReceiveMessage object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidCloseWithCode:) name:WebSocketMgrNotificationDidCloseWithCode object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidReceivePong:) name:WebSocketMgrNotificationDidReceivePong object:nil];
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidOpen object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidFailWithError object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidReceiveMessage object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidCloseWithCode object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidReceivePong object:nil];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[WebSocketMgr standard] reconnect];
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

- (void)initUI {
	self.view.backgroundColor = [UIColor whiteColor];

	self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
	self.scrollView.delegate = self;
	self.scrollView.maximumZoomScale = 2.0f;
	self.scrollView.contentSize = self.view.bounds.size;
	self.scrollView.alwaysBounceHorizontal = NO;
	self.scrollView.alwaysBounceVertical = YES;
	self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.scrollView.backgroundColor = UIColorFromRGB(32, 111, 255);
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

	static const CGFloat kTopButtonWidth                          = 30.0f;
	static const CGFloat kTopButtonHeight                         = 30.0f;
	static const CGFloat kTopButtonMarginTop                      = 18.0f;
	static const CGFloat kProfileButtonMarginLeft                 = 10.0f;
	static const CGFloat kShareButtonMarginRight                  = 10.0f;

	CGRect profileButtonFrame = {.origin.x = kProfileButtonMarginLeft,
		.origin.y = kTopButtonMarginTop,
		.size.width = kTopButtonWidth,
		.size.height = kTopButtonHeight};
	profileButton = [[HJWButton alloc] initWithFrame:profileButtonFrame titleString:@"9" titleColor:[UIColor whiteColor] font:UIFontFromSize(15) logoImg:nil backgroundImage:[UIImage imageExtrude:[UIImage imageNamed:@"startButton_normal"]]];
	[profileButton setBackgroundImage:[UIImage imageExtrude:[UIImage imageNamed:@"startButton_hover"]] forState:UIControlStateHighlighted];
	[profileButton addTarget:self action:@selector(profileButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:profileButton];

	CGRect shareButtonFrame = {.origin.x = SCREEN_WIDTH - kShareButtonMarginRight - kTopButtonWidth,
		.origin.y = kTopButtonMarginTop,
		.size.width = kTopButtonWidth,
		.size.height = kTopButtonHeight};
	shareButton = [[HJWButton alloc] initWithFrame:shareButtonFrame
									   titleString:nil
										titleColor:[UIColor whiteColor]
											  font:UIFontFromSize(15)
										   logoImg:[UIImage imageExtrude:[UIImage imageNamed:@"setting_share"]]
								   backgroundImage:[UIImage imageExtrude:[UIImage imageNamed:@"startButton_normal"]]];
	[shareButton setBackgroundImage:[UIImage imageExtrude:[UIImage imageNamed:@"startButton_hover"]] forState:UIControlStateHighlighted];
	[shareButton addTarget:self action:@selector(profileButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:shareButton];

}

- (void)sendPing:(id)sender;
{
	[[WebSocketMgr standard] sendPing:nil];
}

- (void)viewDidAppear:(BOOL)animated;
{
	//[self.navigationController setNavigationBarHidden:YES animated:animated];
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[[WebSocketMgr standard] close];
	//[self.navigationController setNavigationBarHidden:NO animated:animated];
	[super viewDidDisappear:animated];
}

- (void)loadData {
	[MiaAPIHelper getNearbyWithLatitude:-22 longitude:33 start:1 item:3];
}

#pragma mark - Notification

-(void)notificationWebSocketDidOpen:(NSNotification *)notification {
	[MiaAPIHelper sendUUID];
	[self loadData];

}
-(void)notificationWebSocketDidFailWithError:(NSNotification *)notification {
	// TODO linyehui
	// 长连接初始化失败的时候需要有提示
}

-(void)notificationWebSocketDidReceiveMessage:(NSNotification *)notification {
	NSString *command = [notification userInfo][MiaAPIKey_ServerCommand];
	NSLog(@"%@", command);

	if ([command isEqualToString:MiaAPICommand_Music_GetNearby]) {
		[self handleNearbyFeeds:[notification userInfo]];
	} else if ([command isEqualToString:MiaAPICommand_User_PostGuest]) {
		NSLog(@"without guid, we can do nothing.");
		// TODO linyehui
		// 没有GUID的时候后续的获取信息都会失败
	}

}

-(void)notificationWebSocketDidCloseWithCode:(NSNotification *)notification {
	self.title = @"Connection Closed! (see logs)";
}

-(void)notificationWebSocketDidReceivePong:(NSNotification *)notification {
//	NSLog(@"RadioViewController Websocket received pong");
}

#pragma mark - RadioViewDelegate

- (void)notifyPing {
	[self sendPing:nil];
}

- (void)notifyLogin {
	NSString *testLoginData = @"{\"c\":\"User.Post.Login\",\"r\":\"1\",\"s\":\"123456789\",\"v\":{\"phone\":\"13267189403\",\"pwd\":\"e10adc3949ba59abbe56e057f20f883e\",\"imei\":\"1223333\",\"dev\":\"1\"}}";
	[[WebSocketMgr standard] send:testLoginData];
}

- (void)notifyReconnect {
	[[WebSocketMgr standard] reconnect];
	self.title = @"Opening Connection...";
}

- (void)notifyPlayCompletion {
	[self showNextShare];
}

#pragma mark - received message from websocket

- (void)handleNearbyFeeds:(NSDictionary *) userInfo {
	NSArray *shareList = userInfo[@"v"][@"data"];
	if (!shareList)
		return;

	[shareListMgr addSharesWithArray:shareList];

	if (isLoading) {
		[self showNextShare];
		isLoading = NO;
	}

	[shareListMgr saveChanges];
}

- (ShareItem *)showNextShare {
	ShareItem *currentItem = [shareListMgr popShareItem];
	if ([shareListMgr getOnlineCount] == 0) {
		[MiaAPIHelper getNearbyWithLatitude:-22 longitude:33 start:1 item:1];
	}

	[self.radioView setShareItem:currentItem];

	return currentItem;
}

- (void)profileButtonAction:(id)sender {}
- (void)shareButtonAction:(id)sender {}

@end
