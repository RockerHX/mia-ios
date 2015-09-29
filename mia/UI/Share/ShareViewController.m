//
//  ShareViewController.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "ShareViewController.h"
#import "MIAButton.h"
#import "MIALabel.h"
#import "KYCircularView.h"
#import "MBProgressHUD.h"
#import "MBProgressHUDHelp.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Extrude.h"
#import "CommentCollectionViewCell.h"
#import "DetailHeaderView.h"
#import "MiaAPIHelper.h"
#import "WebSocketMgr.h"
#import "MusicPlayerMgr.h"
#import "Masonry.h"
#import <CoreLocation/CoreLocation.h>
#import "CLLocation+YCLocation.h"

const static CGFloat kShareTopViewHeight		= 280;

@interface ShareViewController () <UITextFieldDelegate, CLLocationManagerDelegate>

@end

@implementation ShareViewController {
	ShareItem *shareItem;

	MIAButton *commentButton;

	UIView *footerView;
	MBProgressHUD *progressHUD;

	/// new++++++++++++++++++++++++++
	MIAButton *sendButton;

	UIView *topView;
	UIView *playerView;
	UIView *addMusicView;
	UIView *bottomView;

	UIImageView *coverImageView;
	KYCircularView *progressView;
	MIAButton *playButton;

	MIALabel *musicNameLabel;
	MIALabel *musicArtistLabel;
	MIALabel *sharerLabel;
//	UITextView *noteTextView;
	UITextField *commentTextField;

	MIALabel *locationLabel;

	NSTimer *progressTimer;
	CLLocationManager *mylocationManager;
	CLLocationCoordinate2D currentCoordinate;
	NSString *currentAddress;
}

- (id)init {
	self = [super init];
	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidReceiveMessage:) name:WebSocketMgrNotificationDidReceiveMessage object:nil];

		//添加键盘监听
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationMusicPlayerMgrDidPlay:) name:MusicPlayerMgrNotificationDidPlay object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationMusicPlayerMgrDidPause:) name:MusicPlayerMgrNotificationDidPause object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationMusicPlayerMgrCompletion:) name:MusicPlayerMgrNotificationCompletion object:nil];
	}

	return self;
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidReceiveMessage object:nil];

	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

	[[NSNotificationCenter defaultCenter] removeObserver:self name:MusicPlayerMgrNotificationDidPlay object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MusicPlayerMgrNotificationDidPause object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MusicPlayerMgrNotificationCompletion object:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self initUI];
	[self initLocationMgr];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated;
{
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
	return NO;
}

- (void)initUI {
	static NSString *kDetailTitle = @"分享";
	self.title = kDetailTitle;
	self.view.backgroundColor = [UIColor whiteColor];
	[self initBarButton];

	UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
	gesture.numberOfTapsRequired = 1;
	[self.view addGestureRecognizer:gesture];

	[self initTopView];
	[self initBottomView];
}

- (void)initBarButton {
	UIImage *backButtonImage = [UIImage imageNamed:@"back"];
	MIAButton *backButton = [[MIAButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, backButtonImage.size.width, backButtonImage.size.height)
												 titleString:nil
												  titleColor:nil
														font:nil
													 logoImg:nil
											 backgroundImage:backButtonImage];
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	self.navigationItem.leftBarButtonItem = leftButton;
	[backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];

	const static CGFloat kSendButtonWidth		= 40;
	const static CGFloat kSendButtonHeight		= 20;

	sendButton = [[MIAButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kSendButtonWidth, kSendButtonHeight)
												 titleString:@"发送"
												  titleColor:UIColorFromHex(@"ff300e", 1.0)
														font:UIFontFromSize(15)
													 logoImg:nil
											 backgroundImage:nil];
	[sendButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
	rightButton.enabled = NO;
	self.navigationItem.rightBarButtonItem = rightButton;
	[sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initTopView {
	topView = [[UIView alloc] initWithFrame:CGRectMake(0,
													   StatusBarHeight + self.navigationController.navigationBar.frame.size.height,
													   self.view.bounds.size.width,
													   kShareTopViewHeight)];
//	topView.backgroundColor = [UIColor orangeColor];
	[self.view addSubview:topView];

	static const CGFloat kCoverWidth = 163;
	static const CGFloat kCoverHeight = 163;
	static const CGFloat kCoverMarginTop = 35;

	static const CGFloat kMusicNameMarginTop = kCoverMarginTop + kCoverHeight + 20;
	static const CGFloat kMusicNameMarginLeft = 20;
	static const CGFloat kMusicArtistMarginLeft = 10;
	static const CGFloat kMusicNameHeight = 20;
	static const CGFloat kMusicArtistHeight = 20;

	static const CGFloat kSharerMarginLeft = 20;
	static const CGFloat kSharerMarginTop = kMusicNameMarginTop + kMusicNameHeight + 5;
	static const CGFloat kSharerHeight = 20;
	static const CGFloat kSharerLabelWidth = 80;

	static const CGFloat kNoteMarginLeft = 103;
	static const CGFloat kNoteMarginTop = kSharerMarginTop + 2;
	static const CGFloat kNoteWidth = 200;
	static const CGFloat kNoteHeight = 20;

	CGRect coverFrame = CGRectMake((topView.bounds.size.width - kCoverWidth) / 2,
								   kCoverMarginTop,
								   kCoverWidth,
								   kCoverHeight);
	[self initPlayerViewWithCoverFrame:coverFrame];
	[self initAddMusicViewWithCoverFrame:coverFrame];

	musicNameLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kMusicNameMarginLeft,
														  kMusicNameMarginTop,
														  topView.bounds.size.width / 2 - kMusicNameMarginLeft + kMusicArtistMarginLeft,
														  kMusicNameHeight)
										  text:@"Castle Walls"
										  font:UIFontFromSize(15.0f)
										   textColor:[UIColor blackColor]
									   textAlignment:NSTextAlignmentRight
								   numberLines:1];
	[topView addSubview:musicNameLabel];

	musicArtistLabel = [[MIALabel alloc] initWithFrame:CGRectMake(topView.bounds.size.width / 2 + kMusicArtistMarginLeft,
																  kMusicNameMarginTop,
																  topView.bounds.size.width / 2 - kMusicArtistMarginLeft,
																  kMusicArtistHeight)
												  text:@"-Mercy"
												  font:UIFontFromSize(15.0f)
											 textColor:[UIColor grayColor]
										 textAlignment:NSTextAlignmentLeft
										   numberLines:1];
	[topView addSubview:musicArtistLabel];

	sharerLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kSharerMarginLeft,
															 kSharerMarginTop,
															 kSharerLabelWidth,
															 kSharerHeight)
											 text:@"Aaronbing:"
											 font:UIFontFromSize(15.0f)
										textColor:[UIColor blueColor]
									textAlignment:NSTextAlignmentRight
									  numberLines:1];
	//sharerLabel.backgroundColor = [UIColor yellowColor];
	[topView addSubview:sharerLabel];

	commentTextField = [[UITextField alloc] initWithFrame:CGRectMake(kNoteMarginLeft,
																	 kNoteMarginTop,
																	 kNoteWidth,
																	 kNoteHeight)];
	commentTextField.borderStyle = UITextBorderStyleNone;
	commentTextField.backgroundColor = [UIColor clearColor];
	commentTextField.textColor = UIColorFromHex(@"#a2a2a2", 1.0);
	commentTextField.placeholder = @"说说此刻的想法";
	[commentTextField setFont:UIFontFromSize(16)];
	commentTextField.keyboardType = UIKeyboardTypeDefault;
	commentTextField.returnKeyType = UIReturnKeySend;
	commentTextField.delegate = self;
	//commentTextField.backgroundColor = [UIColor yellowColor];
	[commentTextField setValue:UIColorFromHex(@"#949494", 1.0) forKeyPath:@"_placeholderLabel.textColor"];
	[commentTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

	[topView addSubview:commentTextField];
}

- (void)initProgressViewWithCoverFrame:(CGRect) coverFrame
{
	progressView = [[KYCircularView alloc] initWithFrame:CGRectInset(coverFrame, -4, -4)];
	progressView.colors = @[(__bridge id)ColorHex(0x206fff).CGColor, (__bridge id)ColorHex(0x206fff).CGColor];
	progressView.backgroundColor = UIColorFromHex(@"dfdfdf", 255.0);
	progressView.lineWidth = 8.0;

	CGFloat pathWidth = progressView.frame.size.width;
	CGFloat pathHeight = progressView.frame.size.height;
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:CGPointMake(pathWidth / 2, pathHeight)];
	[path addLineToPoint:CGPointMake(pathWidth, pathHeight)];
	[path addLineToPoint:CGPointMake(pathWidth, 0)];
	[path addLineToPoint:CGPointMake(0, 0)];
	[path addLineToPoint:CGPointMake(0, pathHeight)];
	[path addLineToPoint:CGPointMake(pathWidth / 2, pathHeight)];
	[path closePath];

	progressView.path = path;

	[topView addSubview:progressView];
}

- (void)initPlayerViewWithCoverFrame:(CGRect)coverFrame {
	playerView = [[UIView alloc] initWithFrame:coverFrame];
	playerView.backgroundColor = [UIColor brownColor];
	[topView addSubview:playerView];

	progressView = [[KYCircularView alloc] initWithFrame:CGRectInset(playerView.bounds, -4, -4)];
	progressView.colors = @[(__bridge id)ColorHex(0x206fff).CGColor, (__bridge id)ColorHex(0x206fff).CGColor];
	progressView.backgroundColor = UIColorFromHex(@"dfdfdf", 255.0);
	progressView.lineWidth = 8.0;

	CGFloat pathWidth = progressView.frame.size.width;
	CGFloat pathHeight = progressView.frame.size.height;
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:CGPointMake(pathWidth / 2, pathHeight)];
	[path addLineToPoint:CGPointMake(pathWidth, pathHeight)];
	[path addLineToPoint:CGPointMake(pathWidth, 0)];
	[path addLineToPoint:CGPointMake(0, 0)];
	[path addLineToPoint:CGPointMake(0, pathHeight)];
	[path addLineToPoint:CGPointMake(pathWidth / 2, pathHeight)];
	[path closePath];

	progressView.path = path;

	[playerView addSubview:progressView];

	static const CGFloat kPlayButtonWidth			= 35;
	static const CGFloat kPlayButtonHeight			= 35;
	static const CGFloat kPlayButtonMarginBottom	= 12;
	static const CGFloat kPlayButtonMarginRight		= 12;

	coverImageView = [[UIImageView alloc] initWithFrame:playerView.bounds];
	[coverImageView sd_setImageWithURL:nil
					  placeholderImage:[UIImage imageNamed:@"default_cover"]];
	[playerView addSubview:coverImageView];

	playButton = [[MIAButton alloc] initWithFrame:CGRectMake(playerView.bounds.origin.x + playerView.bounds.size.width - kPlayButtonMarginRight - kPlayButtonWidth,
															 playerView.bounds.origin.y + playerView.bounds.size.height - kPlayButtonMarginBottom - kPlayButtonHeight,
															 kPlayButtonWidth,
															 kPlayButtonHeight)
									  titleString:nil
									   titleColor:nil
											 font:nil
										  logoImg:nil
								  backgroundImage:nil];
	[playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
	[playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[playerView addSubview:playButton];

	playerView.hidden = YES;
}

- (void)initAddMusicViewWithCoverFrame:(CGRect)coverFrame {
	addMusicView = [[UIView alloc] initWithFrame:coverFrame];
	//addMusicView.backgroundColor = [UIColor greenColor];
	[topView addSubview:addMusicView];

	UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedAddMusic)];
	gesture.numberOfTapsRequired = 1;
	[addMusicView addGestureRecognizer:gesture];

	UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:addMusicView.bounds];
	[bgImageView setImage:[UIImage imageNamed:@"add_music_bg"]];
	[addMusicView addSubview:bgImageView];

	UIImage *logoImage = [UIImage imageNamed:@"add_music_logo"];
	UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake((addMusicView.bounds.size.width - logoImage.size.width) / 2,
																			   addMusicView.bounds.size.height / 2 - logoImage.size.height,
																			   logoImage.size.width,
																			   logoImage.size.height)];
	[logoImageView setImage:logoImage];
	[addMusicView addSubview:logoImageView];

	const static CGFloat kAddMusicLabelHeight = 25;
	MIALabel *addMusicLabel = [[MIALabel alloc] initWithFrame:CGRectMake(0,
															   addMusicView.bounds.size.height / 2 + 5,
															   addMusicView.bounds.size.width,
															   kAddMusicLabelHeight)
											   text:@"添加音乐"
											   font:UIFontFromSize(15.0f)
									   textColor:[UIColor grayColor]
								   textAlignment:NSTextAlignmentCenter
									 numberLines:1];
	[addMusicView addSubview:addMusicLabel];
}

- (void)initBottomView {
	bottomView = [UIView new];
	[self.view addSubview:bottomView];
	bottomView.hidden = YES;
	//bottomView.backgroundColor = [UIColor redColor];

	UIImageView *locationImageView = [[UIImageView alloc] init];
	[locationImageView setImage:[UIImage imageNamed:@"location"]];
	//locationImageView.backgroundColor = [UIColor greenColor];
	[bottomView addSubview:locationImageView];

	locationLabel = [[MIALabel alloc] initWithFrame:CGRectZero
											   text:@""
											   font:UIFontFromSize(12.0f)
									   textColor:[UIColor grayColor]
								   textAlignment:NSTextAlignmentLeft
									 numberLines:1];
	//locationLabel.backgroundColor = [UIColor yellowColor];
	[bottomView addSubview:locationLabel];

	MIAButton *closeButton = [[MIAButton alloc] initWithFrame:CGRectZero
										 titleString:nil
										  titleColor:nil
												font:nil
											 logoImg:nil
									 backgroundImage:[UIImage imageNamed:@"close"]];
	[closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	//closeButton.backgroundColor = [UIColor greenColor];
	[bottomView addSubview:closeButton];

	const static CGFloat kShareBottomViewHeight 		= 20;
	const static CGFloat kShareBottomViewMarginBottom	= 5;
	const static CGFloat kBottomButtonWidth				= 15;
	const static CGFloat kBottomButtonHeight			= 15;
	const static CGFloat kCloseButtonWidth				= 10;

	[bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@(kShareBottomViewHeight));
		make.centerX.equalTo(self.view.mas_centerX);
		make.bottom.equalTo(self.view.mas_bottom).offset(-kShareBottomViewMarginBottom);
	}];

	[locationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.size.mas_equalTo(CGSizeMake(kBottomButtonWidth, kBottomButtonHeight));
		make.left.equalTo(bottomView.mas_left);
		make.centerY.equalTo(bottomView.mas_centerY);
	}];
	[locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(locationImageView.mas_right).offset(5);
		make.right.equalTo(bottomView.mas_right).offset(-kBottomButtonWidth);
		make.centerY.equalTo(bottomView.mas_centerY);
		make.height.equalTo(bottomView.mas_height);
	}];
	[closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.size.mas_equalTo(CGSizeMake(kCloseButtonWidth, kCloseButtonWidth));
		//make.left.equalTo(locationLabel.mas_right);
		make.right.equalTo(bottomView.mas_right);
		make.centerY.equalTo(bottomView.mas_centerY);
	}];

}

- (void)initLocationMgr {
	if (nil == mylocationManager)
		mylocationManager = [[CLLocationManager alloc] init];

	mylocationManager.delegate = self;

	//设置定位的精度
	mylocationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;

	//设置定位服务更新频率
	mylocationManager.distanceFilter = 500;

	if ([[[UIDevice currentDevice] systemVersion] doubleValue]>=8.0) {

		[mylocationManager requestWhenInUseAuthorization];	// 前台定位
		//[mylocationManager requestAlwaysAuthorization];	// 前后台同时定位
	}

	[mylocationManager startUpdatingLocation];
}

- (void)checkSubmitButtonStatus {
	if ([commentTextField.text length] <= 0) {
		[self.navigationItem.rightBarButtonItem setEnabled:NO];
	} else {
		[self.navigationItem.rightBarButtonItem setEnabled:YES];
	}
}

- (void)updateLocationInfo:(CLLocationCoordinate2D)coordinate address:(NSString *)address {
	currentCoordinate = coordinate;
	currentAddress = address;

	locationLabel.text = address;
	bottomView.hidden = NO;
}

- (void)showMBProgressHUD{
	if(!progressHUD){
		UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
		progressHUD = [[MBProgressHUD alloc] initWithView:window];
		[window addSubview:progressHUD];
		progressHUD.dimBackground = YES;
		progressHUD.labelText = @"正在提交评论";
		[progressHUD show:YES];
	}
}

- (void)removeMBProgressHUD:(BOOL)isSuccess removeMBProgressHUDBlock:(RemoveMBProgressHUDBlock)removeMBProgressHUDBlock{
	if(progressHUD){
		if(isSuccess){
			progressHUD.labelText = @"评论成功";
		}else{
			progressHUD.labelText = @"评论失败，请稍后再试";
		}
		progressHUD.mode = MBProgressHUDModeText;
		[progressHUD showAnimated:YES whileExecutingBlock:^{
			sleep(1);
		} completionBlock:^{
			[progressHUD removeFromSuperview];
			progressHUD = nil;
			if(removeMBProgressHUDBlock)
				removeMBProgressHUDBlock();
		}];
	}
}

#pragma mark - delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == commentTextField) {
		[textField resignFirstResponder];
	}

	return true;
}

- (void)textFieldDidChange:(id) sender {
	[self checkSubmitButtonStatus];
}

// 获取地理位置变化的起始点和终点,didUpdateToLocation：
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

	CLLocation * location = [[CLLocation alloc]initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
	CLLocation * marsLoction =   [location locationMarsFromEarth];
	NSLog(@"didUpdateToLocation 当前位置的纬度:%.2f--经度%.2f", marsLoction.coordinate.latitude, marsLoction.coordinate.latitude);


	CLGeocoder *geocoder=[[CLGeocoder alloc]init];
	[geocoder reverseGeocodeLocation:marsLoction completionHandler:^(NSArray *placemarks,NSError *error) {
		if (placemarks.count > 0) {
			CLPlacemark *placemark = [placemarks objectAtIndex:0];
			NSLog(@"______%@", placemark.locality);
			NSLog(@"______%@", placemark.subLocality);
			NSLog(@"______%@", placemark.name);

			[self updateLocationInfo:marsLoction.coordinate
							 address:[NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.subLocality]];
		}
	 }];

	[manager stopUpdatingLocation];
}

#pragma mark - Notification

- (void)notificationWebSocketDidReceiveMessage:(NSNotification *)notification {
//	NSString *command = [notification userInfo][MiaAPIKey_ServerCommand];
//	id ret = [notification userInfo][MiaAPIKey_Values][MiaAPIKey_Return];
//	NSLog(@"%@", command);

//	if ([command isEqualToString:MiaAPICommand_Music_GetMcomm]) {
//		[self handleGetMusicCommentWitRet:[ret intValue] userInfo:[notification userInfo]];
//	}
}

//- (void)handlePostCommentWitRet:(int)ret userInfo:(NSDictionary *) userInfo {
//	BOOL isSuccess = (0 == ret);
//
//	if (isSuccess) {
//		commentTextField.text = @"";
//		[self requestLatestComments];
//	} else {
//	}
//
//	[self removeMBProgressHUD:isSuccess removeMBProgressHUDBlock:^{
//		if (isSuccess) {
//		}
//	}];
//}

/*
 *   即将显示键盘的处理
 */
- (void)keyBoardWillShow:(NSNotification *)notification{
	NSDictionary *info = [notification userInfo];
	//获取当前显示的键盘高度
	CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey ] CGRectValue].size;
	[self moveUpViewForKeyboard:keyboardSize];
}

- (void)keyBoardWillHide:(NSNotification *)notification{
	[self resumeView];
}

- (void)notificationMusicPlayerMgrDidPlay:(NSNotification *)notification {
	[playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
	progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
}

- (void)notificationMusicPlayerMgrDidPause:(NSNotification *)notification {
	[playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
	[progressTimer invalidate];
}

- (void)notificationMusicPlayerMgrCompletion:(NSNotification *)notification {
	[playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
	[progressTimer invalidate];
}

#pragma mark - keyboard

- (void)moveUpViewForKeyboard:(CGSize)keyboardSize {
	NSTimeInterval animationDuration = 0.30f;
	[UIView beginAnimations:@"ResizeForKeyboard" context:nil];
	[UIView setAnimationDuration:animationDuration];

	CGFloat offset = keyboardSize.height - (self.view.bounds.size.height - topView.frame.origin.y - topView.frame.size.height);
	if (offset > 0) {
		CGRect rect = CGRectMake(0,
						  StatusBarHeight + self.navigationController.navigationBar.frame.size.height - offset,
						  self.view.bounds.size.width,
						  kShareTopViewHeight);
		topView.frame = rect;
	}

	[UIView commitAnimations];
}

- (void)resumeView {
	NSTimeInterval animationDuration = 0.30f;
	[UIView beginAnimations:@"ResizeForKeyboard" context:nil];
	[UIView setAnimationDuration:animationDuration];
	CGRect rect = CGRectMake(0,
							 StatusBarHeight + self.navigationController.navigationBar.frame.size.height,
							 self.view.bounds.size.width,
							 kShareTopViewHeight);
	topView.frame = rect;
	[UIView commitAnimations];
}

- (void)hidenKeyboard {
	[commentTextField resignFirstResponder];
	[self checkSubmitButtonStatus];
}

- (void)touchedAddMusic {
	NSLog(@"touchedAddMusic ...");
}

#pragma mark - button Actions

- (void)backButtonAction:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)sendButtonAction:(id)sender {
	NSLog(@"send button clicked.");
}

- (void)closeButtonAction:(id)sender {
	bottomView.hidden = YES;
}

- (void)playButtonAction:(id)sender {
	NSLog(@"playButtonAction");
	if ([[MusicPlayerMgr standard] isPlaying]) {
		[self pauseMusic];
	} else {
		[self playMusic];
	}
}

- (void)favoriteButtonAction:(id)sender {
	NSLog(@"favoriteButtonAction");
}

#pragma mark - audio operations

- (void)playMusic {
	// todo

//	NSString *musicUrl = [[_shareItem music] murl];
//	NSString *musicTitle = [[_shareItem music] name];
//	NSString *musicArtist = [[_shareItem music] singerName];
//
//	if (!musicUrl || !musicTitle || !musicArtist) {
//		NSLog(@"Music is nil, stop play it.");
//		return;
//	}
//
//	[[MusicPlayerMgr standard] playWithUrl:musicUrl andTitle:musicTitle andArtist:musicArtist];
	[playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
}

- (void)pauseMusic {
	[[MusicPlayerMgr standard] pause];
	[playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
}

- (void)stopMusic {
	[[MusicPlayerMgr standard] stop];
	[playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
}

- (void)updateProgress:(NSTimer *)timer {
	float postion = [[MusicPlayerMgr standard] getPlayPosition];
	[progressView setProgress:postion];
}

@end
