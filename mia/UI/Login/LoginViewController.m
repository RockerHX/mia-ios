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
#import "SignUpViewController.h"
#import "ResetPwdViewController.h"
#import "MiaAPIHelper.h"
#import "WebSocketMgr.h"
#import "MBProgressHUDHelp.h"
#import "UserSession.h"
#import "NSString+MD5.h"
#import "UserDefaultsUtils.h"
#import "HXAlertBanner.h"


typedef void(^BackBlock)(BOOL success);

static const CGFloat kBackButtonMarginLeft		= 10;
static const CGFloat kBackButtonMarginTop		= 32;
static const CGFloat kLogoMarginTop				= 125;

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

	MBProgressHUD 	*_progressHUD;
    
    BackBlock _backBlock;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
	[self initUI];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

- (void)initUI {
	self.view.backgroundColor = [UIColor redColor];

	UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	[bgImageView setImage:[UIImage imageNamed:@"login_bg"]];
	[self.view addSubview:bgImageView];

	[self initGuidView];
	[self initLoginView];

	UIImage *backButtonImage = [UIImage imageNamed:@"MD-BackIcon"];
	CGRect backButtonFrame = {.origin.x = kBackButtonMarginLeft,
		.origin.y = kBackButtonMarginTop,
		.size.width = backButtonImage.size.width * 2,
		.size.height = backButtonImage.size.height * 2};
	_backButton = [[MIAButton alloc] initWithFrame:backButtonFrame
									  titleString:@""
									   titleColor:[UIColor whiteColor]
											 font:UIFontFromSize(16)
										  logoImg:backButtonImage
								  backgroundImage:nil];
	[_backButton setContentMode:UIViewContentModeCenter];
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
	[signUpButton setBackgroundImage:[UIImage imageNamed:@"button_gray"] forState:UIControlStateHighlighted];
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
	[signInButton setBackgroundImage:[UIImage imageNamed:@"button_dark_blue"] forState:UIControlStateHighlighted];
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
	static const CGFloat kForgotPwdWidth			= 65;
	static const CGFloat kForgotPwdHeight			= 20;
	static const CGFloat kLoginMarginTop			= kPasswordMarginTop + kTextEditHeight + 45;

	_userNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(kLoginButtonMarginLeft,
																	  kUserNameMarginTop,
																	  _loginView.frame.size.width - 2 * kLoginButtonMarginLeft,
																	  kTextEditHeight)];
	_userNameTextField.borderStyle = UITextBorderStyleNone;
	_userNameTextField.backgroundColor = [UIColor clearColor];
	_userNameTextField.textColor = [UIColor whiteColor];
	_userNameTextField.placeholder = @"输入手机号";
	[_userNameTextField setFont:UIFontFromSize(16)];
	_userNameTextField.keyboardType = UIKeyboardTypePhonePad;
	_userNameTextField.returnKeyType = UIReturnKeyNext;
	_userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	_userNameTextField.delegate = self;
	[_userNameTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
	//userNameTextField.backgroundColor = [UIColor redColor];
	[_loginView addSubview:_userNameTextField];

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
	_passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	_passwordTextField.delegate = self;
	[_passwordTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
	[_loginView addSubview:_passwordTextField];

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
														 font:UIFontFromSize(14)
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
	[loginButton setBackgroundImage:[UIImage imageNamed:@"button_dark_blue"] forState:UIControlStateHighlighted];
	[loginButton addTarget:self action:@selector(loginButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[_loginView addSubview:loginButton];
}

- (void)saveAuthInfo {
	NSString *userName = _userNameTextField.text;
	NSString *passwordHash = [NSString md5HexDigest:_passwordTextField.text];

	[UserDefaultsUtils saveValue:userName forKey:UserDefaultsKey_UserName];
	[UserDefaultsUtils saveValue:passwordHash forKey:UserDefaultsKey_PasswordHash];
}

#pragma mark - Actions
- (void)backButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
	if (_customDelegate && [_customDelegate respondsToSelector:@selector(loginViewControllerDismissWithoutLogin)]) {
		[_customDelegate loginViewControllerDismissWithoutLogin];
	}
}

- (void)signUpButtonAction:(id)sender {
    SignUpViewController *vc = [[SignUpViewController alloc] init];
    vc.signUpViewControllerDelegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)signInButtonAction:(id)sender {
    [_guidView setHidden:YES];
    [_loginView setHidden:NO];
    [_userNameTextField becomeFirstResponder];
}


- (void)forgotPwdButtonAction:(id)sender {
    ResetPwdViewController *vc = [[ResetPwdViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)loginButtonAction:(id)sender {
    if (_userNameTextField.text.length <= 0) {
        [HXAlertBanner showWithMessage:@"请输入登录手机号码" tap:nil];
        return;
    }
    
    if (_passwordTextField.text.length <= 0) {
        [HXAlertBanner showWithMessage:@"请输入登录密码" tap:nil];
        return;
    }
    
    __weak __typeof__(self)weakSelf = self;
    MBProgressHUD *aMBProgressHUD = [MBProgressHUDHelp showLoadingWithText:@"登录中..."];
    NSString *passwordHash = [NSString md5HexDigest:_passwordTextField.text];
    [MiaAPIHelper loginWithPhoneNum:_userNameTextField.text
                       passwordHash:passwordHash
                      completeBlock:
     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
         __strong __typeof__(self)strongSelf = weakSelf;
         if (success) {
             [strongSelf.view endEditing:YES];
             
             [[UserSession standard] setUid:userInfo[MiaAPIKey_Values][@"uid"]];
             [[UserSession standard] setNick:userInfo[MiaAPIKey_Values][@"nick"]];
             [[UserSession standard] setUtype:userInfo[MiaAPIKey_Values][@"utype"]];
             [[UserSession standard] setUnreadCommCnt:userInfo[MiaAPIKey_Values][@"unreadCommCnt"]];
             
             NSString *avatarUrl = userInfo[MiaAPIKey_Values][@"userpic"];
             NSString *avatarUrlWithTime = [NSString stringWithFormat:@"%@?t=%ld", avatarUrl, (long)[[NSDate date] timeIntervalSince1970]];
             [[UserSession standard] setAvatar:avatarUrlWithTime];
             
             [strongSelf saveAuthInfo];
             [UserDefaultsUtils saveValue:userInfo[MiaAPIKey_Values][@"uid"] forKey:UserDefaultsKey_UID];
             [UserDefaultsUtils saveValue:userInfo[MiaAPIKey_Values][@"nick"] forKey:UserDefaultsKey_Nick];
             
             if (strongSelf.customDelegate && [strongSelf.customDelegate respondsToSelector:@selector(loginViewControllerDidSuccess)]) {
                 [strongSelf.customDelegate loginViewControllerDidSuccess];
             }
             
             if (_backBlock) {
                 _backBlock(YES);
             }
             [UserSession standard].state = UserSessionLoginStateLogin;
             
             [strongSelf dismissViewControllerAnimated:YES completion:nil];
         } else {
             id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
             [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
         }
         
         [aMBProgressHUD removeFromSuperview];
     } timeoutBlock:^(MiaRequestItem *requestItem) {
         [HXAlertBanner showWithMessage:@"请求超时，请稍后重试" tap:nil];
         [aMBProgressHUD removeFromSuperview];
     }];
}

#pragma mark - Public Methods
- (void)loginSuccess:(void (^)(BOOL))success {
    _backBlock = success;
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

- (void)signUpViewControllerDidSuccess {
	[_guidView setHidden:YES];
	[_loginView setHidden:NO];
}

@end
