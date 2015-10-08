//
//  SettingViewController.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "SettingViewController.h"
#import "MIAButton.h"
#import "MIALabel.h"
#import "MiaAPIHelper.h"
#import "WebSocketMgr.h"
#import "MBProgressHUD.h"
#import "MBProgressHUDHelp.h"
#import "Masonry.h"

@interface SettingViewController ()

@end

@implementation SettingViewController {
	UIView			*_userSettingView;
	UIView			*_playSettingView;
	UIView			*_versionView;
	UIView			*_logoutView;

	MBProgressHUD 	*_progressHUD;
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidReceiveMessage object:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self initUI];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidReceiveMessage:) name:WebSocketMgrNotificationDidReceiveMessage object:nil];
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

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
	return NO;
}

- (void)initUI {
	static NSString *kSettingTitle = @"设置";
	self.title = kSettingTitle;
	[self.view setBackgroundColor:UIColorFromHex(@"f0eff5", 1.0)];

	[self initBarButton];
	//[self initUserSettingView];
	[self initPlaySettingView];
	[self initVersionView];
	[self initLogoutView];
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
}

- (void)initPlaySettingView {
	_playSettingView = [[UIView alloc] init];
	_playSettingView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:_playSettingView];

	MIALabel *autoPlayLabel = [[MIALabel alloc] initWithFrame:CGRectZero
											 text:@"启动后自动播放"
											 font:UIFontFromSize(15.0f)
										textColor:[UIColor blackColor]
									textAlignment:NSTextAlignmentLeft
									  numberLines:1];
	[_playSettingView addSubview:autoPlayLabel];
	UISwitch *autoPlaySwitch = [[UISwitch alloc] init];
	[autoPlaySwitch setOn:YES];
	[autoPlaySwitch addTarget:self action:@selector(autoPlaySwitchAction:) forControlEvents:UIControlEventValueChanged];
	[_playSettingView addSubview:autoPlaySwitch];

	MIALabel *playWith3GLabel = [[MIALabel alloc] initWithFrame:CGRectZero
														 text:@"在2G/3G/4G网络下播放"
														 font:UIFontFromSize(15.0f)
													textColor:[UIColor blackColor]
												textAlignment:NSTextAlignmentLeft
												  numberLines:1];
	[_playSettingView addSubview:playWith3GLabel];
	UISwitch *playWith3GSwitch = [[UISwitch alloc] init];
	[playWith3GSwitch setOn:NO];
	[playWith3GSwitch addTarget:self action:@selector(playWith3GSwitchAction:) forControlEvents:UIControlEventValueChanged];
	[_playSettingView addSubview:playWith3GSwitch];

	UIView *lineView = [[UIView alloc] init];
	lineView.backgroundColor = UIColorFromHex(@"eaeaea", 1.0);
	[_playSettingView addSubview:lineView];

	[_playSettingView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@100);
		make.left.equalTo(self.view.mas_left);
		make.top.equalTo(self.view.mas_top).offset(StatusBarHeight + self.navigationController.navigationBar.frame.size.height + 15);
		make.right.equalTo(self.view.mas_right);
	}];
	[autoPlayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.width.equalTo(@200);
		make.left.equalTo(_playSettingView.mas_left).offset(15);
		make.top.equalTo(_playSettingView.mas_top).offset(15);
		make.bottom.equalTo(_playSettingView.mas_centerY).offset(-15);
	}];
	[autoPlaySwitch mas_makeConstraints:^(MASConstraintMaker *make) {
		make.width.equalTo(@50);
		make.right.equalTo(_playSettingView.mas_right).offset(-15);
		make.top.equalTo(_playSettingView.mas_top).offset(10);
		make.bottom.equalTo(_playSettingView.mas_centerY).offset(-10);
	}];
	[playWith3GLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.width.equalTo(@200);
		make.left.equalTo(_playSettingView.mas_left).offset(15);
		make.top.equalTo(_playSettingView.mas_centerY).offset(15);
		make.bottom.equalTo(_playSettingView.mas_bottom).offset(-15);
	}];
	[playWith3GSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
		make.width.equalTo(@50);
		make.right.equalTo(_playSettingView.mas_right).offset(-15);
		make.top.equalTo(_playSettingView.mas_centerY).offset(10);
		make.bottom.equalTo(_playSettingView.mas_bottom).offset(-10);
	}];
	[lineView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@1);
		make.left.equalTo(_playSettingView.mas_left).offset(15);
		make.right.equalTo(_playSettingView.mas_right);
		make.centerY.equalTo(_playSettingView.mas_centerY);
	}];

}

- (void)initVersionView {
	_versionView = [[UIView alloc] init];
	_versionView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:_versionView];

	MIALabel *versionTitleLabel = [[MIALabel alloc] initWithFrame:CGRectZero
														 text:@"当前版本"
														 font:UIFontFromSize(15.0f)
													textColor:[UIColor blackColor]
												textAlignment:NSTextAlignmentLeft
												  numberLines:1];
	[_versionView addSubview:versionTitleLabel];

	NSString *buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	NSString *shortVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	NSString *version = [NSString stringWithFormat:@"V%@.%@", shortVersion, buildVersion];

	MIALabel *versionLabel = [[MIALabel alloc] initWithFrame:CGRectZero
															 text:version
															 font:UIFontFromSize(15.0f)
														textColor:UIColorFromHex(@"a2a2a2", 1.0)
													textAlignment:NSTextAlignmentRight
													  numberLines:1];
	[_versionView addSubview:versionLabel];

	[_versionView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.mas_left);
		make.right.equalTo(self.view.mas_right);
		make.height.equalTo(@50);
		make.top.equalTo(_playSettingView.mas_bottom).offset(15);
	}];
	[versionTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(_versionView.mas_centerY);
		make.left.equalTo(_versionView.mas_left).offset(15);
		make.width.equalTo(@200);
	}];
	[versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(_versionView.mas_centerY);
		make.right.equalTo(_versionView.mas_right).offset(-15);
		make.width.equalTo(@200);
	}];
}

- (void)initLogoutView {
	_logoutView = [[UIView alloc] init];
	_logoutView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:_logoutView];

	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoutTouchAction:)];
	[_logoutView addGestureRecognizer:tap];

	MIALabel *logoutTitleLabel = [[MIALabel alloc] initWithFrame:CGRectZero
															 text:@"退出登录"
															 font:UIFontFromSize(15.0f)
														textColor:[UIColor blackColor]
													textAlignment:NSTextAlignmentLeft
													  numberLines:1];
	[_logoutView addSubview:logoutTitleLabel];

	[_logoutView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.mas_left);
		make.right.equalTo(self.view.mas_right);
		make.height.equalTo(@50);
		make.top.equalTo(_playSettingView.mas_bottom).offset(15);
	}];
	[logoutTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(_logoutView.mas_centerY);
		make.left.equalTo(_logoutView.mas_left).offset(15);
		make.width.equalTo(@200);
	}];
}

- (void)showMBProgressHUD{
	if(!_progressHUD){
		UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
		_progressHUD = [[MBProgressHUD alloc] initWithView:window];
		[window addSubview:_progressHUD];
		_progressHUD.dimBackground = YES;
		_progressHUD.labelText = @"正在提交注册";
		[_progressHUD show:YES];
	}
}

- (void)removeMBProgressHUD:(BOOL)isSuccess removeMBProgressHUDBlock:(RemoveMBProgressHUDBlock)removeMBProgressHUDBlock{
	if(_progressHUD){
		if(isSuccess){
			_progressHUD.labelText = @"密码重置成功，请登录";
		}else{
			_progressHUD.labelText = @"密码重置失败，请稍后再试";
		}
		_progressHUD.mode = MBProgressHUDModeText;
		[_progressHUD showAnimated:YES whileExecutingBlock:^{
			sleep(1);
		} completionBlock:^{
			[_progressHUD removeFromSuperview];
			_progressHUD = nil;
			if(removeMBProgressHUDBlock)
				removeMBProgressHUDBlock();
		}];
	}
}

#pragma mark - delegate


#pragma mark - Notification

-(void)notificationWebSocketDidReceiveMessage:(NSNotification *)notification {
	NSString *command = [notification userInfo][MiaAPIKey_ServerCommand];
	id ret = [notification userInfo][MiaAPIKey_Values][MiaAPIKey_Return];

//	NSLog(@"command:%@, ret:%d", command, [ret intValue]);

	if ([command isEqualToString:MiaAPICommand_User_PostPauth]) {
		[self handleGetVerificationCode:[ret intValue] userInfo:[notification userInfo]];
	}
}

- (void)handleGetVerificationCode:(int)ret userInfo:(NSDictionary *) userInfo {
	if (0 == ret) {
		//[self showErrorMsg:@"验证码已经发送"];
	} else {
		//[self showErrorMsg:@"验证码发送失败，请重新获取"];
	}
}

#pragma mark - button Actions

- (void)backButtonAction:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)autoPlaySwitchAction:(id)sender {
	NSLog(@"playWith3GSwitchAction");
}
- (void)playWith3GSwitchAction:(id)sender {
	NSLog(@"autoPlaySwitchAction");
}

- (void)logoutTouchAction:(id)sender {
	NSLog(@"logoutTouchAction");
}

@end
