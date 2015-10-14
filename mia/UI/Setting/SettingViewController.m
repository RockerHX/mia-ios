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
#import "UserSession.h"
#import "UserSetting.h"

@interface SettingViewController ()

@end

@implementation SettingViewController {
	UIView			*_userInfoView;
	UIView			*_playSettingView;
	UIView			*_versionView;
	UIView			*_logoutView;

	UISwitch 		*_autoPlaySwitch;
	UISwitch 		*_playWith3GSwitch;

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
	[self initUserInfoView];
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

- (void)initUserInfoView {
	_userInfoView = [[UIView alloc] init];
	_userInfoView.backgroundColor = [UIColor redColor];
	[self.view addSubview:_userInfoView];

	UIView *avatarView = [[UIView alloc] init];
	avatarView.backgroundColor = [UIColor yellowColor];
	[_userInfoView addSubview:avatarView];

	MIALabel *avatarTitleLabel = [[MIALabel alloc] initWithFrame:CGRectZero
															 text:@"头像"
															 font:UIFontFromSize(15.0f)
														textColor:[UIColor blackColor]
													textAlignment:NSTextAlignmentLeft
													  numberLines:1];
	[avatarView addSubview:avatarTitleLabel];

	UIImageView *avatarImageView = [[UIImageView alloc] init];
	[avatarImageView setImage:[UIImage imageNamed:@"default_avatar"]];
	[avatarView addSubview:avatarImageView];

	UIView *avatarLineView = [[UIView alloc] init];
	avatarLineView.backgroundColor = UIColorFromHex(@"eaeaea", 1.0);
	[avatarView addSubview:avatarLineView];


	[_userInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@220);
		make.left.equalTo(self.view.mas_left);
		make.top.equalTo(self.view.mas_top).offset(StatusBarHeight + self.navigationController.navigationBar.frame.size.height + 15);
		make.right.equalTo(self.view.mas_right);
	}];
	[avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@70);
		make.left.equalTo(_userInfoView.mas_left);
		make.top.equalTo(_userInfoView.mas_top);
		make.right.equalTo(_userInfoView.mas_right);
	}];
	[avatarTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.width.equalTo(@200);
		make.height.equalTo(@20);
		make.left.equalTo(avatarView.mas_left).offset(15);
		make.bottom.equalTo(avatarView.mas_bottom).offset(-17);
	}];
	[avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.size.mas_equalTo(CGSizeMake(45, 45));
		make.right.equalTo(avatarView.mas_right).offset(-15);
		make.centerY.equalTo(avatarView.mas_centerY);
	}];
	[avatarLineView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@1);
		make.left.equalTo(avatarView.mas_left).offset(15);
		make.right.equalTo(avatarView.mas_right);
		make.bottom.equalTo(avatarView.mas_bottom);
	}];

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
	_autoPlaySwitch = [[UISwitch alloc] init];
	[_autoPlaySwitch setOn:[UserSetting autoPlay]];
	[_autoPlaySwitch addTarget:self action:@selector(autoPlaySwitchAction:) forControlEvents:UIControlEventValueChanged];
	[_playSettingView addSubview:_autoPlaySwitch];

	MIALabel *playWith3GLabel = [[MIALabel alloc] initWithFrame:CGRectZero
														 text:@"在2G/3G/4G网络下播放"
														 font:UIFontFromSize(15.0f)
													textColor:[UIColor blackColor]
												textAlignment:NSTextAlignmentLeft
												  numberLines:1];
	[_playSettingView addSubview:playWith3GLabel];
	_playWith3GSwitch = [[UISwitch alloc] init];
	[_playWith3GSwitch setOn:[UserSetting playWith3G]];
	[_playWith3GSwitch addTarget:self action:@selector(playWith3GSwitchAction:) forControlEvents:UIControlEventValueChanged];
	[_playSettingView addSubview:_playWith3GSwitch];

	UIView *lineView = [[UIView alloc] init];
	lineView.backgroundColor = UIColorFromHex(@"eaeaea", 1.0);
	[_playSettingView addSubview:lineView];

	[_playSettingView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@100);
		make.left.equalTo(self.view.mas_left);
		make.top.equalTo(_userInfoView.mas_bottom).offset(15);
		make.right.equalTo(self.view.mas_right);
	}];
	[autoPlayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.width.equalTo(@200);
		make.left.equalTo(_playSettingView.mas_left).offset(15);
		make.top.equalTo(_playSettingView.mas_top).offset(15);
		make.bottom.equalTo(_playSettingView.mas_centerY).offset(-15);
	}];
	[_autoPlaySwitch mas_makeConstraints:^(MASConstraintMaker *make) {
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
	[_playWith3GSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
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
		_progressHUD.labelText = @"退出登录中...";
		[_progressHUD show:YES];
	}
}

- (void)removeMBProgressHUD:(BOOL)isSuccess removeMBProgressHUDBlock:(RemoveMBProgressHUDBlock)removeMBProgressHUDBlock{
	if(_progressHUD){
		if(isSuccess){
			_progressHUD.labelText = @"成功退出登录，请重新登录";
		}else{
			_progressHUD.labelText = @"退出登录失败，请稍后再试";
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

- (void)notificationWebSocketDidReceiveMessage:(NSNotification *)notification {
	NSString *command = [notification userInfo][MiaAPIKey_ServerCommand];
	id ret = [notification userInfo][MiaAPIKey_Values][MiaAPIKey_Return];

//	NSLog(@"command:%@, ret:%d", command, [ret intValue]);

	if ([command isEqualToString:MiaAPICommand_User_PostLogout]) {
		[self handleLogoutWithRet:[ret intValue] userInfo:[notification userInfo]];
	}
}

- (void)handleLogoutWithRet:(int)ret userInfo:(NSDictionary *) userInfo {
	BOOL isSuccess = (0 == ret);
	[self removeMBProgressHUD:isSuccess removeMBProgressHUDBlock:nil];
	if (isSuccess) {
		[[UserSession standard] logout];
		[self.navigationController popToRootViewControllerAnimated:YES];
	}
}

#pragma mark - button Actions

- (void)backButtonAction:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)autoPlaySwitchAction:(id)sender {
	[UserSetting setAutoPlay:_autoPlaySwitch.isOn];
}

- (void)playWith3GSwitchAction:(id)sender {
	[UserSetting setPlayWith3G:_playWith3GSwitch.isOn];
}

- (void)logoutTouchAction:(id)sender {
	[self showMBProgressHUD];
	[MiaAPIHelper logout];
}

@end
