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
	MIAButton 		*_backButton;

	UIView 			*_guidView;			// 注册或者登录两个按钮
	UIView 			*_loginView;		// 输入框和登录按钮的页面

	UITextField 	*_userNameTextField;
	UITextField 	*_passwordTextField;
	MIALabel 		*_userNameErrorLabel;
	MIALabel 		*_passwordErrorLabel;

	MBProgressHUD 	*_progressHUD;
}

-(void)dealloc {
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self initUI];
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

- (void)viewDidAppear:(BOOL)animated {
	[self.navigationController setNavigationBarHidden:YES animated:animated];
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[self.navigationController setNavigationBarHidden:NO animated:animated];
	[super viewDidDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
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
	_backButton = [[MIAButton alloc] initWithFrame:backButtonFrame
									  titleString:@""
									   titleColor:[UIColor whiteColor]
											 font:UIFontFromSize(15)
										  logoImg:nil
								  backgroundImage:backButtonImage];
	[_backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_backButton];
}

- (void)initGuidView {
	_guidView = [[UIView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:_guidView];

	UIImage *logoImage = [UIImage imageNamed:@"login_logo"];
	UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake((_guidView.frame.size.width - logoImage.size.width) / 2,
																			   kLogoMarginTop,
																			   logoImage.size.width,
																			   logoImage.size.height)];
	[logoImageView setImage:logoImage];
	[_guidView addSubview:logoImageView];

	CGRect signUpButtonFrame = {.origin.x = kGuidButtonMarginLeft,
		.origin.y = _guidView.frame.size.height - kSignUpMarginBottom - kGuidButtonHeight,
		.size.width = _guidView.frame.size.width - 2 * kGuidButtonMarginLeft,
		.size.height = kGuidButtonHeight};
	MIAButton *signUpButton = [[MIAButton alloc] initWithFrame:signUpButtonFrame
												   titleString:@"注册"
													titleColor:[UIColor blackColor]
														  font:UIFontFromSize(16)
													   logoImg:nil
											   backgroundImage:[UIImage imageExtrude:[UIImage imageNamed:@"button_white"]]];
	[signUpButton addTarget:self action:@selector(signUpButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[_guidView addSubview:signUpButton];

	CGRect signInButtonFrame = {.origin.x = kGuidButtonMarginLeft,
		.origin.y = _guidView.frame.size.height - kSignInMarginBottom - kGuidButtonHeight,
		.size.width = _guidView.frame.size.width - 2 * kGuidButtonMarginLeft,
		.size.height = kGuidButtonHeight};
	MIAButton *signInButton = [[MIAButton alloc] initWithFrame:signInButtonFrame
												   titleString:@"登录"
													titleColor:[UIColor whiteColor]
														  font:UIFontFromSize(16)
													   logoImg:nil
											   backgroundImage:[UIImage imageExtrude:[UIImage imageNamed:@"button_blue"]]];
	[signInButton addTarget:self action:@selector(signInButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[_guidView addSubview:signInButton];
}

- (void)initLoginView {
	_loginView = [[UIView alloc] initWithFrame:self.view.bounds];
	//loginView.backgroundColor = [UIColor yellowColor];
	_loginView.hidden = YES;
	[self.view addSubview:_loginView];

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



	_userNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(kLoginButtonMarginLeft,
																	  kUserNameMarginTop,
																	  _loginView.frame.size.width - 2 * kLoginButtonMarginLeft,
																	  kTextEditHeight)];
	_userNameTextField.borderStyle = UITextBorderStyleNone;
	_userNameTextField.backgroundColor = [UIColor clearColor];
	_userNameTextField.textColor = [UIColor whiteColor];
	_userNameTextField.placeholder = @"输入手机号";
	[_userNameTextField setFont:UIFontFromSize(16)];
	_userNameTextField.keyboardType = UIKeyboardTypeNumberPad;
	_userNameTextField.returnKeyType = UIReturnKeyNext;
	_userNameTextField.delegate = self;
	[_userNameTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
	//userNameTextField.backgroundColor = [UIColor redColor];
	[_loginView addSubview:_userNameTextField];

	_userNameErrorLabel = [[MIALabel alloc] initWithFrame:CGRectMake(_loginView.frame.size.width - kUserNameErrorMarginRight - kUserNameErrorWidth,
																				  kUserNameErrorMarginTop,
																				  kUserNameErrorWidth,
																				  kUserNameErrorHeight)
																  text:@""
																  font:UIFontFromSize(12.0f)
															 textColor:[UIColor whiteColor]
														 textAlignment:NSTextAlignmentRight
														   numberLines:1];
	//userNameErrorLabel.backgroundColor = [UIColor yellowColor];
	[_loginView addSubview:_userNameErrorLabel];

	UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(kLoginButtonMarginLeft,
																	   kUserNameMarginTop + kTextEditHeight,
																	   _loginView.frame.size.width - 2 * kLoginButtonMarginLeft,
																	   0.5)];
	lineView1.backgroundColor = [UIColor grayColor];
	[_loginView addSubview:lineView1];

	_passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(kLoginButtonMarginLeft,
																	  kPasswordMarginTop,
																	  _loginView.frame.size.width - 2 * kLoginButtonMarginLeft,
																	  kTextEditHeight)];
	_passwordTextField.borderStyle = UITextBorderStyleNone;
	_passwordTextField.backgroundColor = [UIColor clearColor];
	_passwordTextField.textColor = [UIColor whiteColor];
	_passwordTextField.placeholder = @"密码";
	_passwordTextField.secureTextEntry = YES;
	[_passwordTextField setFont:UIFontFromSize(16)];
	_passwordTextField.keyboardType = UIKeyboardTypeDefault;
	_passwordTextField.returnKeyType = UIReturnKeyDone;
	_passwordTextField.delegate = self;
	[_passwordTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
	[_loginView addSubview:_passwordTextField];

	_passwordErrorLabel = [[MIALabel alloc] initWithFrame:CGRectMake(_loginView.frame.size.width - kPasswordErrorMarginRight - kPasswordErrorWidth,
																	kPasswordErrorMarginTop,
																	kPasswordErrorWidth,
																	kPasswordErrorHeight)
													text:@""
													font:UIFontFromSize(12.0f)
											   textColor:[UIColor whiteColor]
										   textAlignment:NSTextAlignmentRight
											 numberLines:1];
	//passwordErrorLabel.backgroundColor = [UIColor yellowColor];
	[_loginView addSubview:_passwordErrorLabel];

	UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(kLoginButtonMarginLeft,
																 kPasswordMarginTop + kTextEditHeight,
																 _loginView.frame.size.width - 2 * kLoginButtonMarginLeft,
																 0.5)];
	lineView2.backgroundColor = [UIColor grayColor];
	[_loginView addSubview:lineView2];

	CGRect forgotPwdButtonFrame = {.origin.x = _loginView.frame.size.width - kForgotPwdMarginRight - kForgotPwdWidth,
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
	[_loginView addSubview:forgotPwdButton];


	CGRect loginButtonFrame = {.origin.x = kLoginButtonMarginLeft,
		.origin.y = kLoginMarginTop,
		.size.width = _loginView.frame.size.width - 2 * kLoginButtonMarginLeft,
		.size.height = kGuidButtonHeight};
	MIAButton *loginButton = [[MIAButton alloc] initWithFrame:loginButtonFrame
												   titleString:@"登录"
													titleColor:[UIColor whiteColor]
														  font:UIFontFromSize(16)
													   logoImg:nil
											   backgroundImage:[UIImage imageExtrude:[UIImage imageNamed:@"button_blue"]]];
	[loginButton addTarget:self action:@selector(loginButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[_loginView addSubview:loginButton];
}

- (void)saveAuthInfo {
	NSString *userName = _userNameTextField.text;
	NSString *passwordHash = [NSString md5HexDigest:_passwordTextField.text];

	[UserDefaultsUtils saveValue:userName forKey:UserDefaultsKey_UserName];
	[UserDefaultsUtils saveValue:passwordHash forKey:UserDefaultsKey_PasswordHash];
}

#pragma mark - delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == _userNameTextField) {
		[_passwordTextField becomeFirstResponder];
	}
	else if (textField == _passwordTextField) {
		[_passwordTextField resignFirstResponder];
	}

	return true;
}

- (void)signUpViewControllerDidSuccess{
	[_guidView setHidden:YES];
	[_loginView setHidden:NO];
}

#pragma mark - Notification

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
	[_guidView setHidden:YES];
	[_loginView setHidden:NO];
}


- (void)forgotPwdButtonAction:(id)sender {
	ResetPwdViewController *vc = [[ResetPwdViewController alloc] init];
	[self.navigationController pushViewController:vc animated:YES];
}

- (void)loginButtonAction:(id)sender {
	if (_userNameTextField.text.length <= 0) {
		[_userNameErrorLabel setText:@"手机号码不能为空"];
		return;
	}
	[_userNameErrorLabel setText:@""];

	if (_passwordTextField.text.length <= 0) {
		[_passwordErrorLabel setText:@"密码不能为空"];
		return;
	}
	[_passwordErrorLabel setText:@""];

	MBProgressHUD *aMBProgressHUD = [MBProgressHUDHelp showLoadingWithText:@"登录中..."];
	NSString *passwordHash = [NSString md5HexDigest:_passwordTextField.text];
	[MiaAPIHelper loginWithPhoneNum:_userNameTextField.text
					   passwordHash:passwordHash
					  completeBlock:
	 ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
		 if (success) {
			 [[UserSession standard] setUid:userInfo[MiaAPIKey_Values][@"uid"]];
			 [[UserSession standard] setNick:userInfo[MiaAPIKey_Values][@"nick"]];
			 [[UserSession standard] setUtype:userInfo[MiaAPIKey_Values][@"utype"]];
			 [[UserSession standard] setUnreadCommCnt:userInfo[MiaAPIKey_Values][@"unreadCommCnt"]];

			 NSString *avatarUrl = userInfo[MiaAPIKey_Values][@"userpic"];
			 NSString *avatarUrlWithTime = [NSString stringWithFormat:@"%@?t=%ld", avatarUrl, (long)[[NSDate date] timeIntervalSince1970]];
			 [[UserSession standard] setAvatar:avatarUrlWithTime];

			 [self saveAuthInfo];
			 [UserDefaultsUtils saveValue:userInfo[MiaAPIKey_Values][@"uid"] forKey:UserDefaultsKey_UID];
			 [UserDefaultsUtils saveValue:userInfo[MiaAPIKey_Values][@"nick"] forKey:UserDefaultsKey_Nick];

			 if (_loginViewControllerDelegate) {
				 [_loginViewControllerDelegate loginViewControllerDidSuccess];
			 }
			 [self.navigationController popViewControllerAnimated:YES];
		 } else {
			 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
			 [_passwordErrorLabel setText:[NSString stringWithFormat:@"%@", error]];
		 }

		 [aMBProgressHUD removeFromSuperview];
	 } timeoutBlock:^(MiaRequestItem *requestItem) {
		 [_passwordErrorLabel setText:[NSString stringWithFormat:@"请求超时，请稍后重试"]];
		 [aMBProgressHUD removeFromSuperview];
	 }];
}

@end
