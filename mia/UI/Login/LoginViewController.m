//
//  LoginViewController.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "LoginViewController.h"
#import "UIImage+ColorToImage.h"
#import "UIImage+Extrude.h"
#import "MIAButton.h"
#import "MIALabel.h"
#import "SignUpViewController.h"
#import "ResetPwdViewController.h"
#import "MiaAPIHelper.h"
#import "WebSocketMgr.h"
#import "MBProgressHUD.h"
#import "MBProgressHUDHelp.h"
#import "UserSession.h"
#import "NSString+MD5.h"
#import "UserDefaultsUtils.h"

static const CGFloat kBackButtonMarginLeft		= 15;
static const CGFloat kBackButtonMarginTop		= 32;
static const CGFloat kLogoMarginTop				= 90;

static const CGFloat kGuidButtonHeight			= 40;
static const CGFloat kGuidButtonMarginLeft		= 30;
static const CGFloat kSignInMarginBottom		= 50;
static const CGFloat kSignUpMarginBottom		= kSignInMarginBottom + kGuidButtonHeight + 15;

@interface LoginViewController () <UITextFieldDelegate, SignUpViewControllerDelegate>

@end

@implementation LoginViewController {
	MIAButton *backButton;

	UIView *guidView;		// 注册或者登录两个按钮

	UIView *loginView;		// 输入框和登录按钮的页面
	UITextField *userNameTextField;
	UITextField *passwordTextField;
	MIALabel *userNameErrorLabel;
	MIALabel *passwordErrorLabel;

	MBProgressHUD *progressHUD;
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

- (void)initUI {
	self.view.backgroundColor = [UIColor redColor];

	UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	[bgImageView setImage:[UIImage imageNamed:@"login_bg"]];
	[self.view addSubview:bgImageView];

	[self initGuidView];
	[self initLoginView];

	UIImage *backButtonImage = [UIImage imageNamed:@"back"];
	CGRect backButtonFrame = {.origin.x = kBackButtonMarginLeft,
		.origin.y = kBackButtonMarginTop,
		.size.width = backButtonImage.size.width,
		.size.height = backButtonImage.size.height};
	backButton = [[MIAButton alloc] initWithFrame:backButtonFrame
									  titleString:@""
									   titleColor:[UIColor whiteColor]
											 font:UIFontFromSize(15)
										  logoImg:nil
								  backgroundImage:backButtonImage];
	[backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
}

- (void)initGuidView {
	guidView = [[UIView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:guidView];

	UIImage *logoImage = [UIImage imageNamed:@"login_logo"];
	UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake((guidView.frame.size.width - logoImage.size.width) / 2,
																			   kLogoMarginTop,
																			   logoImage.size.width,
																			   logoImage.size.height)];
	[logoImageView setImage:logoImage];
	[guidView addSubview:logoImageView];

	CGRect signUpButtonFrame = {.origin.x = kGuidButtonMarginLeft,
		.origin.y = guidView.frame.size.height - kSignUpMarginBottom - kGuidButtonHeight,
		.size.width = guidView.frame.size.width - 2 * kGuidButtonMarginLeft,
		.size.height = kGuidButtonHeight};
	MIAButton *signUpButton = [[MIAButton alloc] initWithFrame:signUpButtonFrame
												   titleString:@"注册"
													titleColor:[UIColor blackColor]
														  font:UIFontFromSize(16)
													   logoImg:nil
											   backgroundImage:[UIImage imageExtrude:[UIImage imageNamed:@"button_white"]]];
	[signUpButton addTarget:self action:@selector(signUpButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[guidView addSubview:signUpButton];

	CGRect signInButtonFrame = {.origin.x = kGuidButtonMarginLeft,
		.origin.y = guidView.frame.size.height - kSignInMarginBottom - kGuidButtonHeight,
		.size.width = guidView.frame.size.width - 2 * kGuidButtonMarginLeft,
		.size.height = kGuidButtonHeight};
	MIAButton *signInButton = [[MIAButton alloc] initWithFrame:signInButtonFrame
												   titleString:@"登录"
													titleColor:[UIColor whiteColor]
														  font:UIFontFromSize(16)
													   logoImg:nil
											   backgroundImage:[UIImage imageExtrude:[UIImage imageNamed:@"button_blue"]]];
	[signInButton addTarget:self action:@selector(signInButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[guidView addSubview:signInButton];
}

- (void)initLoginView {
	loginView = [[UIView alloc] initWithFrame:self.view.bounds];
	//loginView.backgroundColor = [UIColor yellowColor];
	loginView.hidden = YES;
	[self.view addSubview:loginView];

	static const CGFloat kLoginButtonMarginLeft		= 30;
	static const CGFloat kTextEditHeight			= 40;
	static const CGFloat kUserNameMarginTop			= 110;
	static const CGFloat kPasswordMarginTop			= kUserNameMarginTop + kTextEditHeight + 5;
	static const CGFloat kForgotPwdMarginTop		= kPasswordMarginTop + kTextEditHeight + 10;
	static const CGFloat kForgotPwdMarginRight		= kLoginButtonMarginLeft;
	static const CGFloat kForgotPwdWidth			= 50;
	static const CGFloat kForgotPwdHeight			= 20;
	static const CGFloat kLoginMarginTop			= kPasswordMarginTop + kTextEditHeight + 45;

	static const CGFloat kUserNameErrorMarginRight	= kLoginButtonMarginLeft;
	static const CGFloat kUserNameErrorMarginTop	= kUserNameMarginTop + 12;
	static const CGFloat kUserNameErrorWidth		= 100;
	static const CGFloat kUserNameErrorHeight		= 20;
	static const CGFloat kPasswordErrorMarginRight	= kLoginButtonMarginLeft;
	static const CGFloat kPasswordErrorMarginTop	= kPasswordMarginTop + 12;
	static const CGFloat kPasswordErrorWidth		= 100;
	static const CGFloat kPasswordErrorHeight		= 20;



	userNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(kLoginButtonMarginLeft,
																	  kUserNameMarginTop,
																	  loginView.frame.size.width - 2 * kLoginButtonMarginLeft,
																	  kTextEditHeight)];
	userNameTextField.borderStyle = UITextBorderStyleNone;
	userNameTextField.backgroundColor = [UIColor clearColor];
	userNameTextField.textColor = [UIColor whiteColor];
	userNameTextField.placeholder = @"输入手机号";
	[userNameTextField setFont:UIFontFromSize(16)];
	userNameTextField.keyboardType = UIKeyboardTypeNumberPad;
	userNameTextField.returnKeyType = UIReturnKeyNext;
	userNameTextField.delegate = self;
	[userNameTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
	//userNameTextField.backgroundColor = [UIColor redColor];
	[loginView addSubview:userNameTextField];

	userNameErrorLabel = [[MIALabel alloc] initWithFrame:CGRectMake(loginView.frame.size.width - kUserNameErrorMarginRight - kUserNameErrorWidth,
																				  kUserNameErrorMarginTop,
																				  kUserNameErrorWidth,
																				  kUserNameErrorHeight)
																  text:@""
																  font:UIFontFromSize(12.0f)
															 textColor:[UIColor whiteColor]
														 textAlignment:NSTextAlignmentRight
														   numberLines:1];
	//userNameErrorLabel.backgroundColor = [UIColor yellowColor];
	[loginView addSubview:userNameErrorLabel];

	UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(kLoginButtonMarginLeft,
																	   kUserNameMarginTop + kTextEditHeight,
																	   loginView.frame.size.width - 2 * kLoginButtonMarginLeft,
																	   0.5)];
	lineView1.backgroundColor = [UIColor grayColor];
	[loginView addSubview:lineView1];

	passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(kLoginButtonMarginLeft,
																	  kPasswordMarginTop,
																	  loginView.frame.size.width - 2 * kLoginButtonMarginLeft,
																	  kTextEditHeight)];
	passwordTextField.borderStyle = UITextBorderStyleNone;
	passwordTextField.backgroundColor = [UIColor clearColor];
	passwordTextField.textColor = [UIColor whiteColor];
	passwordTextField.placeholder = @"密码";
	passwordTextField.secureTextEntry = YES;
	[passwordTextField setFont:UIFontFromSize(16)];
	passwordTextField.keyboardType = UIKeyboardTypeDefault;
	passwordTextField.returnKeyType = UIReturnKeyDone;
	passwordTextField.delegate = self;
	[passwordTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
	[loginView addSubview:passwordTextField];

	passwordErrorLabel = [[MIALabel alloc] initWithFrame:CGRectMake(loginView.frame.size.width - kPasswordErrorMarginRight - kPasswordErrorWidth,
																	kPasswordErrorMarginTop,
																	kPasswordErrorWidth,
																	kPasswordErrorHeight)
													text:@""
													font:UIFontFromSize(12.0f)
											   textColor:[UIColor whiteColor]
										   textAlignment:NSTextAlignmentRight
											 numberLines:1];
	//passwordErrorLabel.backgroundColor = [UIColor yellowColor];
	[loginView addSubview:passwordErrorLabel];

	UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(kLoginButtonMarginLeft,
																 kPasswordMarginTop + kTextEditHeight,
																 loginView.frame.size.width - 2 * kLoginButtonMarginLeft,
																 0.5)];
	lineView2.backgroundColor = [UIColor grayColor];
	[loginView addSubview:lineView2];

	CGRect forgotPwdButtonFrame = {.origin.x = loginView.frame.size.width - kForgotPwdMarginRight - kForgotPwdWidth,
		.origin.y = kForgotPwdMarginTop,
		.size.width = kForgotPwdWidth,
		.size.height = kForgotPwdHeight};
	MIAButton *forgotPwdButton = [[MIAButton alloc] initWithFrame:forgotPwdButtonFrame
												  titleString:@"忘记密码"
												   titleColor:[UIColor whiteColor]
														 font:UIFontFromSize(12)
													  logoImg:nil
											  backgroundImage:nil];
	[forgotPwdButton addTarget:self action:@selector(forgotPwdButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[loginView addSubview:forgotPwdButton];


	CGRect loginButtonFrame = {.origin.x = kLoginButtonMarginLeft,
		.origin.y = kLoginMarginTop,
		.size.width = loginView.frame.size.width - 2 * kLoginButtonMarginLeft,
		.size.height = kGuidButtonHeight};
	MIAButton *loginButton = [[MIAButton alloc] initWithFrame:loginButtonFrame
												   titleString:@"登录"
													titleColor:[UIColor whiteColor]
														  font:UIFontFromSize(16)
													   logoImg:nil
											   backgroundImage:[UIImage imageExtrude:[UIImage imageNamed:@"button_blue"]]];
	[loginButton addTarget:self action:@selector(loginButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[loginView addSubview:loginButton];
}

- (void)showMBProgressHUD{
	if(!progressHUD){
		UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
		progressHUD = [[MBProgressHUD alloc] initWithView:window];
		[window addSubview:progressHUD];
		progressHUD.dimBackground = YES;
		progressHUD.labelText = @"登录中";
		[progressHUD show:YES];
	}
}

- (void)removeMBProgressHUD:(BOOL)isSuccess removeMBProgressHUDBlock:(RemoveMBProgressHUDBlock)removeMBProgressHUDBlock{
	if(progressHUD){
		if(isSuccess){
			progressHUD.labelText = @"登录成功";
		}else{
			progressHUD.labelText = @"登录失败，请稍后再试";
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

- (void)saveAuthInfo {
	NSString *userName = userNameTextField.text;
	NSString *passwordHash = [NSString md5HexDigest:passwordTextField.text];

	[UserDefaultsUtils saveValue:userName forKey:UserDefaultsKey_UserName];
	[UserDefaultsUtils saveValue:passwordHash forKey:UserDefaultsKey_PasswordHash];
}

#pragma mark - delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == userNameTextField) {
		[passwordTextField becomeFirstResponder];
	}
	else if (textField == passwordTextField) {
		[passwordTextField resignFirstResponder];
	}

	return true;
}

- (void)signUpViewControllerDidSuccess{
	[guidView setHidden:YES];
	[loginView setHidden:NO];
}

#pragma mark - Notification

-(void)notificationWebSocketDidReceiveMessage:(NSNotification *)notification {
	NSString *command = [notification userInfo][MiaAPIKey_ServerCommand];
	id ret = [notification userInfo][MiaAPIKey_Values][MiaAPIKey_Return];

	//	NSLog(@"command:%@, ret:%d", command, [ret intValue]);

	if ([command isEqualToString:MiaAPICommand_User_PostLogin]) {
		[self handleLoginWithRet:[ret intValue] userInfo:[notification userInfo]];
	}
}

- (void)handleLoginWithRet:(int)ret userInfo:(NSDictionary *) userInfo {
	BOOL isSuccess = (0 == ret);

	if (isSuccess) {
		[[UserSession standard] setUid:userInfo[MiaAPIKey_Values][@"uid"]];
		[[UserSession standard] setNick:userInfo[MiaAPIKey_Values][@"nick"]];
		[[UserSession standard] setUtype:userInfo[MiaAPIKey_Values][@"utype"]];
		[[UserSession standard] setUnreadCommCnt:userInfo[MiaAPIKey_Values][@"unreadCommCnt"]];

		[_loginViewControllerDelegate loginViewControllerDidSuccess];
	} else {
		id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
		[passwordErrorLabel setText:[NSString stringWithFormat:@"%@", error]];
	}

	[self removeMBProgressHUD:isSuccess removeMBProgressHUDBlock:^{
		if (isSuccess) {
			[self saveAuthInfo];
			[self.navigationController popViewControllerAnimated:YES];
		}
	}];
}


#pragma mark - Actions

- (void)backButtonAction:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)signUpButtonAction:(id)sender {
	SignUpViewController *vc = [[SignUpViewController alloc] init];
	vc.signUpViewControllerDelegate = self;
	[self.navigationController pushViewController:vc animated:YES];
}

- (void)signInButtonAction:(id)sender {
	[guidView setHidden:YES];
	[loginView setHidden:NO];
}


- (void)forgotPwdButtonAction:(id)sender {
	ResetPwdViewController *vc = [[ResetPwdViewController alloc] init];
	[self.navigationController pushViewController:vc animated:YES];
}

- (void)loginButtonAction:(id)sender {
	if (userNameTextField.text.length <= 0) {
		[userNameErrorLabel setText:@"手机号码不能为空"];
		return;
	}
	[userNameErrorLabel setText:@""];

	if (passwordTextField.text.length <= 0) {
		[passwordErrorLabel setText:@"密码不能为空"];
		return;
	}
	[passwordErrorLabel setText:@""];

	[self showMBProgressHUD];
	NSString *passwordHash = [NSString md5HexDigest:passwordTextField.text];
	[MiaAPIHelper loginWithPhoneNum:userNameTextField.text passwordHash:passwordHash];
}

@end
