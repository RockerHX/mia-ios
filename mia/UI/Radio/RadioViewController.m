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
#import "MIAButton.h"
#import "DetailViewController.h"
#import "LoginViewController.h"
#import "UserSession.h"
#import "UserDefaultsUtils.h"
#import "NSString+IsNull.h"
#import "ProfileViewController.h"

const CGFloat kTopViewDefaultHeight				= 75.0f;
const CGFloat kBottomViewDefaultHeight			= 35.0f;

static NSString * kAlertTitleError			= @"错误提示";
static NSString * kAlertMsgWebSocketFailed	= @"服务器连接错误（WebSocket失败），点击确认重新连接服务器";
static NSString * kAlertMsgSendGUIDFailed	= @"服务器连接错误（发送GUID失败），点击确认重新发送";

@interface RadioViewController () <RadioViewDelegate, UIAlertViewDelegate, LoginViewControllerDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) RadioView *radioView;

@end

@implementation RadioViewController {
	MIAButton *profileButton;
	MIAButton *shareButton;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self initUI];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidOpen:) name:WebSocketMgrNotificationDidOpen object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidFailWithError:) name:WebSocketMgrNotificationDidFailWithError object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidReceiveMessage:) name:WebSocketMgrNotificationDidReceiveMessage object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidCloseWithCode:) name:WebSocketMgrNotificationDidCloseWithCode object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidReceivePong:) name:WebSocketMgrNotificationDidReceivePong object:nil];

	[[WebSocketMgr standard] reconnect];
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
//	[[WebSocketMgr standard] reconnect];
//	self.title = @"Opening Connection...";
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated;
{
	//[self.navigationController setNavigationBarHidden:YES animated:animated];
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	//[[WebSocketMgr standard] close];
	//[self.navigationController setNavigationBarHidden:NO animated:animated];
	[super viewDidDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
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
	__weak RadioViewController *weakSelf = self;
	AAPullToRefresh *tv = [self.scrollView addPullToRefreshPosition:AAPullToRefreshPositionTop actionHandler:^(AAPullToRefresh *v){
		[weakSelf pullReflashFromTop];
		[v performSelector:@selector(stopIndicatorAnimation) withObject:nil afterDelay:1.0f];
	}];
	tv.imageIcon = [UIImage imageNamed:@"launchpad"];
	tv.borderColor = [UIColor whiteColor];

	// bottom
	AAPullToRefresh *bv = [self.scrollView addPullToRefreshPosition:AAPullToRefreshPositionBottom actionHandler:^(AAPullToRefresh *v){
		[weakSelf pullReflashFromBottom];
		[v performSelector:@selector(stopIndicatorAnimation) withObject:nil afterDelay:1.0f];
	}];
	bv.imageIcon = [UIImage imageNamed:@"launchpad"];
	bv.borderColor = [UIColor whiteColor];

	static const CGFloat kTopButtonWidth                          = 40.0f;
	static const CGFloat kTopButtonHeight                         = 40.0f;
	static const CGFloat kTopButtonMarginTop                      = 20.0f;
	static const CGFloat kProfileButtonMarginLeft                 = 15.0f;
	static const CGFloat kShareButtonMarginRight                  = 15.0f;

	CGRect profileButtonFrame = {.origin.x = kProfileButtonMarginLeft,
		.origin.y = kTopButtonMarginTop,
		.size.width = kTopButtonWidth,
		.size.height = kTopButtonHeight};
	profileButton = [[MIAButton alloc] initWithFrame:profileButtonFrame
										 titleString:@""
										  titleColor:UIColorFromHex(@"206fff", 1.0)
												font:UIFontFromSize(15)
											 logoImg:nil
									 backgroundImage:[UIImage imageExtrude:[UIImage imageNamed:@"profile"]]];
	[profileButton addTarget:self action:@selector(profileButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:profileButton];

	CGRect shareButtonFrame = {.origin.x = SCREEN_WIDTH - kShareButtonMarginRight - kTopButtonWidth,
		.origin.y = kTopButtonMarginTop,
		.size.width = kTopButtonWidth,
		.size.height = kTopButtonHeight};
	shareButton = [[MIAButton alloc] initWithFrame:shareButtonFrame
									   titleString:nil
										titleColor:[UIColor whiteColor]
											  font:UIFontFromSize(15)
										   logoImg:nil
								   backgroundImage:[UIImage imageExtrude:[UIImage imageNamed:@"share_music"]]];
	[shareButton addTarget:self action:@selector(profileButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:shareButton];

}

- (void)sendPing:(id)sender;
{
	[[WebSocketMgr standard] sendPing:nil];
}

- (void)initData {
	[self autoLogin];

	// TODO load的调用时机还需要考虑本地是否需要重新加载数据，可能可以用isLoading来判断
	if ([_radioView isLoading]) {
		[MiaAPIHelper getNearbyWithLatitude:-22 longitude:33 start:1 item:3];
	}
}

- (void)updateProfileButtonWithUnreadCount:(int)unreadCommentCount {
	if (unreadCommentCount <= 0) {
		[profileButton setBackgroundImage:[UIImage imageExtrude:[UIImage imageNamed:@"profile"]] forState:UIControlStateNormal];
	} else {
		[profileButton setBackgroundImage:[UIImage imageExtrude:[UIImage imageNamed:@"profile_with_notification"]] forState:UIControlStateNormal];
		[profileButton setTitle:[NSString stringWithFormat:@"%d", unreadCommentCount] forState:UIControlStateNormal];
	}
}

- (void)autoLogin {
	NSString *userName = [UserDefaultsUtils valueWithKey:UserDefaultsKey_UserName];
	NSString *passwordHash = [UserDefaultsUtils valueWithKey:UserDefaultsKey_PasswordHash];
	if ([NSString isNull:userName] || [NSString isNull:passwordHash]) {
		return;
	}

	[MiaAPIHelper loginWithPhoneNum:userName passwordHash:passwordHash];
}

#pragma mark - Notification

- (void)notificationWebSocketDidOpen:(NSNotification *)notification {
	[MiaAPIHelper sendUUID];
}

- (void)notificationWebSocketDidFailWithError:(NSNotification *)notification {
	// TODO linyehui
	// 长连接初始化失败的时候需要有提示
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kAlertTitleError
														message:kAlertMsgWebSocketFailed
													   delegate:self
											  cancelButtonTitle:@"确定"
											  otherButtonTitles:nil];
	[alertView show];
}

- (void)notificationWebSocketDidReceiveMessage:(NSNotification *)notification {
	NSString *command = [notification userInfo][MiaAPIKey_ServerCommand];
	id ret = [notification userInfo][MiaAPIKey_Values][MiaAPIKey_Return];
	//NSLog(@"%@", command);

	if ([command isEqualToString:MiaAPICommand_User_PostGuest]) {
		[self handlePostGuestWithRet:[ret intValue] userInfo:[notification userInfo]];
	} else if ([command isEqualToString:MiaAPICommand_User_PostLogin]) {
		[self handleLoginWithRet:[ret intValue] userInfo:[notification userInfo]];
	}

}

- (void)notificationWebSocketDidCloseWithCode:(NSNotification *)notification {
	self.title = @"Connection Closed! (see logs)";
}

- (void)notificationWebSocketDidReceivePong:(NSNotification *)notification {
//	NSLog(@"RadioViewController Websocket received pong");
}

- (void)handlePostGuestWithRet:(int)ret userInfo:(NSDictionary *) userInfo {
	if (ret != 0) {
		// TODO linyehui
		// 没有GUID的时候后续的获取信息都会失败
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kAlertTitleError
															message:kAlertMsgSendGUIDFailed
														   delegate:self
												  cancelButtonTitle:@"确定"
												  otherButtonTitles:nil];
		[alertView show];
	} else {
		[self initData];
	}
}

- (void)handleLoginWithRet:(int)ret userInfo:(NSDictionary *) userInfo {
	BOOL isSuccess = (0 == ret);

	if (isSuccess) {
		[[UserSession standard] setUid:userInfo[MiaAPIKey_Values][@"uid"]];
		[[UserSession standard] setNick:userInfo[MiaAPIKey_Values][@"nick"]];
		[[UserSession standard] setUtype:userInfo[MiaAPIKey_Values][@"utype"]];
		[[UserSession standard] setUnreadCommCnt:userInfo[MiaAPIKey_Values][@"unreadCommCnt"]];
	} else {
		id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
		NSLog(@"audo login failed!error:%@", error);
	}
}

#pragma mark - delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ([alertView.message isEqual:kAlertMsgWebSocketFailed]) {
		[self notifyReconnect];
	} else if ([alertView.message isEqual:kAlertMsgSendGUIDFailed]) {
		[MiaAPIHelper sendUUID];
	}
}

- (void)loginViewControllerDidSuccess {
	if ([[UserSession standard] isLogined]) {
		int unreadCommentCount = [[[UserSession standard] unreadCommCnt] intValue];
		[self updateProfileButtonWithUnreadCount:unreadCommentCount];
	}
}

#pragma mark - RadioViewDelegate

- (void)radioViewDidTouchBottom {
	if (![_radioView currentShareItem])
		return;
	
	DetailViewController *vc = [[DetailViewController alloc] initWitShareItem:[_radioView currentShareItem]];
	[self.navigationController pushViewController:vc animated:YES];
}

- (void)radioViewShouldLogin {
	LoginViewController *vc = [[LoginViewController alloc] init];
	vc.loginViewControllerDelegate = self;
	[self.navigationController pushViewController:vc animated:YES];
}

- (void)notifyLogin {
	NSString *testLoginData = @"{\"c\":\"User.Post.Login\",\"r\":\"1\",\"s\":\"123456789\",\"v\":{\"phone\":\"13267189403\",\"pwd\":\"e10adc3949ba59abbe56e057f20f883e\",\"imei\":\"1223333\",\"dev\":\"1\"}}";
	[[WebSocketMgr standard] send:testLoginData];
}

- (void)notifyReconnect {
	[[WebSocketMgr standard] reconnect];
	self.title = @"Opening Connection...";
}

#pragma mark - Actions

- (void)profileButtonAction:(id)sender {
	if ([[UserSession standard] isLogined]) {
		NSLog(@"navigator to profile page.");
		ProfileViewController *vc = [[ProfileViewController alloc] init];
		[self.navigationController pushViewController:vc animated:YES];
	} else {
		LoginViewController *vc = [[LoginViewController alloc] init];
		vc.loginViewControllerDelegate = self;
		[self.navigationController pushViewController:vc animated:YES];
	}
}

- (void)shareButtonAction:(id)sender {
	NSLog(@"share button clicked");
}

- (void)pullReflashFromTop {
//	NSLog(@"pullReflashFromTop");
	[_radioView skipFeed];
}

- (void)pullReflashFromBottom {
//	NSLog(@"pullReflashFromBottom");
	[_radioView spreadFeed];
}

@end