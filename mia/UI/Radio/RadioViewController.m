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
#import "ShareViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "CLLocation+YCLocation.h"
#import "UIButton+WebCache.h"

const CGFloat kTopViewDefaultHeight				= 75.0f;
const CGFloat kBottomViewDefaultHeight			= 35.0f;

static NSString * kAlertTitleError				= @"错误提示";
static NSString * kAlertMsgWebSocketFailed		= @"服务器连接错误（WebSocket失败），点击确认重新连接服务器";
static NSString * kAlertMsgSendGUIDFailed		= @"服务器连接错误（发送GUID失败），点击确认重新发送";
static NSString * kAlertMsgNoNetwork			= @"没有网络连接，请稍候重试";

@interface RadioViewController () <RadioViewDelegate, UIAlertViewDelegate, LoginViewControllerDelegate, CLLocationManagerDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) RadioView *radioView;

@end

@implementation RadioViewController {
	MIAButton 				*_profileButton;
	MIAButton 				*_shareButton;
	CLLocationManager 		*_locationManager;
	CLLocationCoordinate2D 	_currentCoordinate;
	NSString				*_currentAddress;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[[WebSocketMgr standard] watchNetworkStatus];
	
	[self initUI];
	[self initLocationMgr];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReachabilityStatusChange:) name:NetworkNotificationReachabilityStatusChange object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidOpen:) name:WebSocketMgrNotificationDidOpen object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidFailWithError:) name:WebSocketMgrNotificationDidFailWithError object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidReceiveMessage:) name:WebSocketMgrNotificationDidReceiveMessage object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidCloseWithCode:) name:WebSocketMgrNotificationDidCloseWithCode object:nil];

	[[UserSession standard] addObserver:self forKeyPath:UserSessionKey_Avatar options:NSKeyValueObservingOptionNew context:nil];
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NetworkNotificationReachabilityStatusChange object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidOpen object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidFailWithError object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidReceiveMessage object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidCloseWithCode object:nil];

	[[UserSession standard] removeObserver:self forKeyPath:UserSessionKey_Avatar context:nil];
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

- (void)viewDidAppear:(BOOL)animated {
	[self.navigationController setNavigationBarHidden:YES animated:animated];
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	//[[WebSocketMgr standard] close];
	[self.navigationController setNavigationBarHidden:NO animated:animated];
	[super viewDidDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
	return YES;
}

- (void)viewWillLayoutSubviews {
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
	_profileButton = [[MIAButton alloc] initWithFrame:profileButtonFrame
										 titleString:@""
										  titleColor:UIColorFromHex(@"206fff", 1.0)
												font:UIFontFromSize(15)
											 logoImg:nil
									 backgroundImage:[UIImage imageExtrude:[UIImage imageNamed:@"profile"]]];
	_profileButton.layer.cornerRadius = _profileButton.frame.size.width / 2;
	_profileButton.clipsToBounds = YES;
	_profileButton.layer.borderWidth = 1.0f;
	_profileButton.layer.borderColor = [UIColor whiteColor].CGColor;
	[_profileButton addTarget:self action:@selector(profileButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_profileButton];

	CGRect shareButtonFrame = {.origin.x = SCREEN_WIDTH - kShareButtonMarginRight - kTopButtonWidth,
		.origin.y = kTopButtonMarginTop,
		.size.width = kTopButtonWidth,
		.size.height = kTopButtonHeight};
	_shareButton = [[MIAButton alloc] initWithFrame:shareButtonFrame
									   titleString:nil
										titleColor:[UIColor whiteColor]
											  font:UIFontFromSize(15)
										   logoImg:nil
								   backgroundImage:[UIImage imageExtrude:[UIImage imageNamed:@"share_music"]]];
	[_shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_shareButton];

}

- (void)initLocationMgr {
	if (nil == _locationManager) {
		_locationManager = [[CLLocationManager alloc] init];
	}

	_locationManager.delegate = self;

	//设置定位的精度
	_locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;

	//设置定位服务更新频率
	_locationManager.distanceFilter = 500;

	if ([[[UIDevice currentDevice] systemVersion] doubleValue]>=8.0) {

		[_locationManager requestWhenInUseAuthorization];	// 前台定位
		//[mylocationManager requestAlwaysAuthorization];	// 前后台同时定位
	}

	[_locationManager startUpdatingLocation];
}

- (void)updateProfileButtonWithUnreadCount:(int)unreadCommentCount {
	if (unreadCommentCount <= 0) {
		[_profileButton setBackgroundImage:[UIImage imageNamed:@"profile"] forState:UIControlStateNormal];
	} else {
		[_profileButton setBackgroundImage:[UIImage imageNamed:@"profile_with_notification"] forState:UIControlStateNormal];
		[_profileButton setTitle:[NSString stringWithFormat:@"%d", unreadCommentCount] forState:UIControlStateNormal];
	}
}

- (BOOL)autoLogin {
	NSString *userName = [UserDefaultsUtils valueWithKey:UserDefaultsKey_UserName];
	NSString *passwordHash = [UserDefaultsUtils valueWithKey:UserDefaultsKey_PasswordHash];
	if ([NSString isNull:userName] || [NSString isNull:passwordHash]) {
		return NO;
	}

	[MiaAPIHelper loginWithPhoneNum:userName passwordHash:passwordHash];
	return YES;
}

#pragma mark - Notification

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//	NSLog(@"keyPath = %@, change = %@, context = %s", keyPath, change, (char *)context);
	if ([keyPath isEqualToString:UserSessionKey_Avatar]) {
		NSString *newAvatarUrl = change[NSKeyValueChangeNewKey];
		if ([NSString isNull:newAvatarUrl]) {
			[_profileButton setImage:[UIImage imageNamed:@"default_avatar"] forState:UIControlStateNormal];
		} else {
			[_profileButton sd_setBackgroundImageWithURL:[NSURL URLWithString:newAvatarUrl]
												forState:UIControlStateNormal
										placeholderImage:[UIImage imageNamed:@"default_avatar"]];
		}

	}
}

- (void)notificationReachabilityStatusChange:(NSNotification *)notification {
	if (![[WebSocketMgr standard] isNetworkEnable]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kAlertTitleError
															message:kAlertMsgNoNetwork
														   delegate:self
												  cancelButtonTitle:@"确定"
												  otherButtonTitles:nil];
		[alertView show];
	} else {
		if ([[WebSocketMgr standard] isClosed]) {
			[[WebSocketMgr standard] reconnect];
		}
	}
}

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
	} else if ([command isEqualToString:MiaAPICommand_User_PushUnreadComm]) {
		[self handlePushUnreadCommWithRet:[ret intValue] userInfo:[notification userInfo]];
	} else if ([command isEqualToString:MiaAPICommand_User_GetUinfo]) {
		[self handleGetUserInfoWithRet:[ret intValue] userInfo:[notification userInfo]];
	}

}

- (void)notificationWebSocketDidCloseWithCode:(NSNotification *)notification {
	NSLog(@"Connection Closed! (see logs)");
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
		if (![self autoLogin]) {
			[_radioView loadShareList];
			[_radioView checkIsNeedToGetNewItems];
		}
	}
}

- (void)handleLoginWithRet:(int)ret userInfo:(NSDictionary *) userInfo {
	BOOL isSuccess = (0 == ret);

	if (isSuccess) {
		[[UserSession standard] setUid:userInfo[MiaAPIKey_Values][@"uid"]];
		[[UserSession standard] setNick:userInfo[MiaAPIKey_Values][@"nick"]];
		[[UserSession standard] setUtype:userInfo[MiaAPIKey_Values][@"utype"]];
		[[UserSession standard] setUnreadCommCnt:userInfo[MiaAPIKey_Values][@"unreadCommCnt"]];

		[MiaAPIHelper getUserInfoWithUID:userInfo[MiaAPIKey_Values][@"uid"]];
	} else {
		NSLog(@"audo login failed!error:%@", userInfo[MiaAPIKey_Values][MiaAPIKey_Error]);
	}

	[_radioView loadShareList];
}

- (void)handlePushUnreadCommWithRet:(int)ret userInfo:(NSDictionary *) userInfo {
	BOOL isSuccess = (0 == ret);

	if (isSuccess) {
		[self updateProfileButtonWithUnreadCount:[userInfo[MiaAPIKey_Values][@"num"] intValue]];
	} else {
		NSLog(@"unread comment failed! error:%@", userInfo[MiaAPIKey_Values][MiaAPIKey_Error]);
	}
}

- (void)handleGetUserInfoWithRet:(int)ret userInfo:(NSDictionary *) userInfo {
	if (0 != ret) {
		NSLog(@"get user info failed! error:%@", userInfo[MiaAPIKey_Values][MiaAPIKey_Error]);
	}

	NSString *avatarUrl = userInfo[MiaAPIKey_Values][@"info"][0][@"uimg"];
	NSString *avatarUrlWithTime = [NSString stringWithFormat:@"%@?t=%ld", avatarUrl, (long)[[NSDate date] timeIntervalSince1970]];
	[_profileButton sd_setBackgroundImageWithURL:[NSURL URLWithString:avatarUrlWithTime]
										forState:UIControlStateNormal
								placeholderImage:[UIImage imageExtrude:[UIImage imageNamed:@"default_avatar"]]];
}

#pragma mark - delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ([alertView.message isEqual:kAlertMsgWebSocketFailed]) {
		[[WebSocketMgr standard] reconnect];
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

// 获取地理位置变化的起始点和终点,didUpdateToLocation：
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

	CLLocation * location = [[CLLocation alloc]initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
	CLLocation * marsLoction =   [location locationMarsFromEarth];
	NSLog(@"didUpdateToLocation 当前位置的纬度:%.2f--经度%.2f", marsLoction.coordinate.latitude, marsLoction.coordinate.longitude);

	CLGeocoder *geocoder=[[CLGeocoder alloc]init];
	[geocoder reverseGeocodeLocation:marsLoction completionHandler:^(NSArray *placemarks,NSError *error) {
		if (placemarks.count > 0) {
			CLPlacemark *placemark = [placemarks objectAtIndex:0];
			NSLog(@"______%@", placemark.locality);
			NSLog(@"______%@", placemark.subLocality);
			NSLog(@"______%@", placemark.name);

			_currentCoordinate = marsLoction.coordinate;
			_currentAddress = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.subLocality];

			[_radioView checkIsNeedToGetNewItems];
		}
	}];

	[manager stopUpdatingLocation];
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

- (void)radioViewStartPlayItem {
	[_locationManager startUpdatingLocation];
}

- (CLLocationCoordinate2D)radioViewCurrentCoordinate {
	return _currentCoordinate;
}

- (NSString *)radioViewCurrentAddress {
	return _currentAddress;
}

#pragma mark - Actions

- (void)profileButtonAction:(id)sender {
	if ([[UserSession standard] isLogined]) {
		ProfileViewController *vc = [[ProfileViewController alloc] initWitUID:[[UserSession standard] uid]
																	 nickName:[[UserSession standard] nick]
																  isMyProfile:YES];
		[self.navigationController pushViewController:vc animated:YES];
	} else {
		LoginViewController *vc = [[LoginViewController alloc] init];
		vc.loginViewControllerDelegate = self;
		[self.navigationController pushViewController:vc animated:YES];
	}
}

- (void)shareButtonAction:(id)sender {
	if ([[UserSession standard] isLogined]) {
		ShareViewController *vc = [[ShareViewController alloc] init];
		[self.navigationController pushViewController:vc animated:YES];
	} else {
		LoginViewController *vc = [[LoginViewController alloc] init];
		vc.loginViewControllerDelegate = self;
		[self.navigationController pushViewController:vc animated:YES];
	}
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
