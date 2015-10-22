//
//  ResetPwdViewController.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "ResetPwdViewController.h"
#import "MIAButton.h"
#import "MIALabel.h"
#import "UIImage+Extrude.h"
#import "UIImage+ColorToImage.h"
#import "MiaAPIHelper.h"
#import "WebSocketMgr.h"
#import "MBProgressHUDHelp.h"
#import "NSString+MD5.h"
#import "HXAlertBanner.h"

@interface ResetPwdViewController () <UITextFieldDelegate>

@end

@implementation ResetPwdViewController {
	UIView 			*_inputView;
	UITextField 	*_userNameTextField;
	UITextField 	*_verificationCodeTextField;
	UITextField 	*_firstPasswordTextField;
	UITextField 	*_secondPasswordTextField;
	MIAButton 		*_resetButton;
	MIAButton 		*_verificationCodeButton;

	UIView 			*_msgView;
	MIALabel 		*_msgLabel;

	NSTimer 		*_verificationCodeTimer;
	int 			_countdown;

	MBProgressHUD 	*_progressHUD;
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidReceiveMessage object:nil];
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

- (void)viewWillAppear:(BOOL)animated {
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
	return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
	return NO;
}

- (void)initUI {
	static NSString *kResetTitle = @"忘记密码";
	self.title = kResetTitle;
	[self.view setBackgroundColor:[UIColor whiteColor]];

	[self initBarButton];
	[self initInputView];
	[self initMsgView];
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

- (void)initInputView {
	_inputView = [[UIView alloc] initWithFrame:self.view.frame];
	[self.view addSubview:_inputView];

	static const CGFloat kTextFieldMarginLeft		= 30;
	static const CGFloat kTextFieldHeight			= 35;
	static const CGFloat kUserNameMarginTop			= 100;
	static const CGFloat kVerificationCodeMarginTop	= kUserNameMarginTop + kTextFieldHeight + 5;
	static const CGFloat kFirstPasswordMarginTop	= kVerificationCodeMarginTop + kTextFieldHeight + 5;
	static const CGFloat kSecondPasswordMarginTop	= kFirstPasswordMarginTop + kTextFieldHeight + 5;
	static const CGFloat kSiginUpMarginTop			= kSecondPasswordMarginTop + kTextFieldHeight + 45;

	static const CGFloat kVerificationCodeButtonWidthMarginTop	= kVerificationCodeMarginTop + 5;
 	static const CGFloat kVerificationCodeButtonWidth			= 80;
	static const CGFloat kVerificationCodeButtonHeight			= 25;

	UIColor *placeHolderColor = UIColorFromHex(@"#c0c0c0", 1.0);
	UIColor *textColor = [UIColor blackColor];
	UIColor *lineColor = UIColorFromHex(@"#eaeaea", 1.0);
	UIFont *textFont = UIFontFromSize(12);

	_userNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																	  kUserNameMarginTop,
																	  self.view.frame.size.width - 2 * kTextFieldMarginLeft,
																	  kTextFieldHeight)];
	_userNameTextField.borderStyle = UITextBorderStyleNone;
	_userNameTextField.backgroundColor = [UIColor clearColor];
	_userNameTextField.textColor = textColor;
	_userNameTextField.placeholder = @"输入手机号";
	[_userNameTextField setFont:textFont];
	_userNameTextField.keyboardType = UIKeyboardTypeNumberPad;
	_userNameTextField.returnKeyType = UIReturnKeyNext;
	_userNameTextField.delegate = self;
	[_userNameTextField setValue:placeHolderColor forKeyPath:@"_placeholderLabel.textColor"];
	[_inputView addSubview:_userNameTextField];

	UIView *userNameLineView = [[UIView alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																		kUserNameMarginTop + kTextFieldHeight,
																		_inputView.frame.size.width - 2 * kTextFieldMarginLeft,
																		0.5)];
	userNameLineView.backgroundColor = lineColor;
	[_inputView addSubview:userNameLineView];

	_verificationCodeTextField = [[UITextField alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																			  kVerificationCodeMarginTop,
																			  _inputView.frame.size.width - 2 * kTextFieldMarginLeft,
																			  kTextFieldHeight)];
	_verificationCodeTextField.borderStyle = UITextBorderStyleNone;
	_verificationCodeTextField.backgroundColor = [UIColor clearColor];
	_verificationCodeTextField.textColor = textColor;
	_verificationCodeTextField.placeholder = @"验证码";
	[_verificationCodeTextField setFont:textFont];
	_verificationCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
	_verificationCodeTextField.returnKeyType = UIReturnKeyNext;
	_verificationCodeTextField.delegate = self;
	[_verificationCodeTextField setValue:placeHolderColor forKeyPath:@"_placeholderLabel.textColor"];
	[_inputView addSubview:_verificationCodeTextField];

	UIView *verificationCodeLineView = [[UIView alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																				kVerificationCodeMarginTop + kTextFieldHeight,
																				_inputView.frame.size.width - 2 * kTextFieldMarginLeft,
																				0.5)];
	verificationCodeLineView.backgroundColor = lineColor;
	[_inputView addSubview:verificationCodeLineView];

	CGRect verificationCodeButtonFrame = CGRectMake(_inputView.frame.size.width - kTextFieldMarginLeft - kVerificationCodeButtonWidth,
											 kVerificationCodeButtonWidthMarginTop,
											 kVerificationCodeButtonWidth,
											 kVerificationCodeButtonHeight);
	_verificationCodeButton = [[MIAButton alloc] initWithFrame:verificationCodeButtonFrame
															   titleString:@"获取验证码"
																titleColor:[UIColor whiteColor]
																	  font:textFont
																   logoImg:nil
														   backgroundImage:[UIImage createImageWithColor:UIColorFromHex(@"ff5959", 1.0)]];
	[_verificationCodeButton setBackgroundImage:[UIImage createImageWithColor:UIColorFromHex(@"ff5959", 1.0)] forState:UIControlStateDisabled];
	[_verificationCodeButton addTarget:self action:@selector(verificationCodeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[_inputView addSubview:_verificationCodeButton];
	[self resetCountdown];

	_firstPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																		   kFirstPasswordMarginTop,
																		   _inputView.frame.size.width - 2 * kTextFieldMarginLeft,
																		   kTextFieldHeight)];
	_firstPasswordTextField.borderStyle = UITextBorderStyleNone;
	_firstPasswordTextField.backgroundColor = [UIColor clearColor];
	_firstPasswordTextField.textColor = textColor;
	_firstPasswordTextField.placeholder = @"登录密码";
	[_firstPasswordTextField setFont:textFont];
	_firstPasswordTextField.secureTextEntry = YES;
	_firstPasswordTextField.keyboardType = UIKeyboardTypeDefault;
	_firstPasswordTextField.returnKeyType = UIReturnKeyNext;
	_firstPasswordTextField.delegate = self;
	[_firstPasswordTextField setValue:placeHolderColor forKeyPath:@"_placeholderLabel.textColor"];
	[_inputView addSubview:_firstPasswordTextField];

	UIView *firstPasswordLineView = [[UIView alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																			 kFirstPasswordMarginTop + kTextFieldHeight,
																			 _inputView.frame.size.width - 2 * kTextFieldMarginLeft,
																			 0.5)];
	firstPasswordLineView.backgroundColor = lineColor;
	[_inputView addSubview:firstPasswordLineView];

	_secondPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																	  kSecondPasswordMarginTop,
																	  _inputView.frame.size.width - 2 * kTextFieldMarginLeft,
																	  kTextFieldHeight)];
	_secondPasswordTextField.borderStyle = UITextBorderStyleNone;
	_secondPasswordTextField.backgroundColor = [UIColor clearColor];
	_secondPasswordTextField.textColor = textColor;
	_secondPasswordTextField.placeholder = @"确认密码";
	[_secondPasswordTextField setFont:textFont];
	_secondPasswordTextField.secureTextEntry = YES;
	_secondPasswordTextField.keyboardType = UIKeyboardTypeDefault;
	_secondPasswordTextField.returnKeyType = UIReturnKeyDone;
	_secondPasswordTextField.delegate = self;
	[_secondPasswordTextField setValue:placeHolderColor forKeyPath:@"_placeholderLabel.textColor"];
	[_inputView addSubview:_secondPasswordTextField];

	UIView *secondPasswordLineView = [[UIView alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																			  kSecondPasswordMarginTop + kTextFieldHeight,
																			  _inputView.frame.size.width - 2 * kTextFieldMarginLeft,
																			  0.5)];
	secondPasswordLineView.backgroundColor = lineColor;
	[_inputView addSubview:secondPasswordLineView];

	CGRect resetButtonFrame = CGRectMake(kTextFieldMarginLeft,
											 kSiginUpMarginTop,
											 _inputView.frame.size.width - 2 * kTextFieldMarginLeft,
											 kTextFieldHeight);
	 _resetButton = [[MIAButton alloc] initWithFrame:resetButtonFrame
													   titleString:@"重置密码"
														titleColor:[UIColor whiteColor]
															  font:UIFontFromSize(16)
														   logoImg:nil
												   backgroundImage:[UIImage createImageWithColor:UIColorFromHex(@"000000", 1.0)]];
	[_resetButton setBackgroundImage:[UIImage createImageWithColor:UIColorFromHex(@"f2f2f2", 1.0)] forState:UIControlStateDisabled];
	[_resetButton setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
	[_resetButton addTarget:self action:@selector(resetButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[_resetButton setEnabled:NO];
	[_inputView addSubview:_resetButton];

	UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
	gesture.numberOfTapsRequired = 1;
	[_inputView addGestureRecognizer:gesture];
}

- (void)initMsgView {
	static const CGFloat kMsgViewMarginTop 		= 64;
	static const CGFloat kMsgViewHeight 		= 35;
	static const CGFloat kLogoMarginLeft 		= 10;
	static const CGFloat kLogoMarginTop 		= 10;
	static const CGFloat kLogoWidth 			= 18;
	static const CGFloat kLogoHeight 			= 18;
	static const CGFloat kMsgLabelMarginLeft 	= 30;
	static const CGFloat kMsgLabelMarginRight	= 15;
	static const CGFloat kMsgLabelMarginTop 	= 8;
	static const CGFloat kMsgLabelHeight 		= 20;


	_msgView = [[UIView alloc] initWithFrame:CGRectMake(0, kMsgViewMarginTop, self.view.frame.size.width, kMsgViewHeight)];
	_msgView.backgroundColor = UIColorFromHex(@"#606060", 1.0);
	[self.view addSubview:_msgView];


	UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kLogoMarginLeft, kLogoMarginTop, kLogoWidth, kLogoHeight)];
	[logoImageView setImage:[UIImage imageNamed:@"info"]];
	[_msgView addSubview:logoImageView];

	_msgLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kMsgLabelMarginLeft,
															  kMsgLabelMarginTop,
															  _msgView.frame.size.width - kMsgLabelMarginLeft - kMsgLabelMarginRight,
															  kMsgLabelHeight)
											  text:@""
											  font:UIFontFromSize(12.0f)
										 textColor:[UIColor whiteColor]
									 textAlignment:NSTextAlignmentLeft
									   numberLines:1];
	[_msgView addSubview:_msgLabel];
	[_msgView setHidden:YES];
}

#pragma mark - delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == _userNameTextField) {
		[_verificationCodeTextField becomeFirstResponder];
	}
	else if (textField == _verificationCodeTextField) {
		[_firstPasswordTextField becomeFirstResponder];
	} else if (textField == _firstPasswordTextField) {
		[_secondPasswordTextField becomeFirstResponder];
	} else if (textField == _secondPasswordTextField) {
		[_secondPasswordTextField resignFirstResponder];
		[self resumeView];
	}

	[self checkResetButtonStatus];
	return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	if (textField == _secondPasswordTextField) {
		[self moveUpViewForKeyboard];
	}

	return YES;
}

#pragma mark - Notification

#pragma mark - keyboard

- (void)moveUpViewForKeyboard {
	NSTimeInterval animationDuration = 0.30f;
	[UIView beginAnimations:@"ResizeForKeyboard" context:nil];
	[UIView setAnimationDuration:animationDuration];
	float width = _inputView.frame.size.width;
	float height = _inputView.frame.size.height;

	static const CGFloat kOffsetForKeyboard = 30;
	CGRect rect = CGRectMake(0.0f, -kOffsetForKeyboard, width,height);
	_inputView.frame = rect;
	[UIView commitAnimations];
}

- (void)resumeView {
	NSTimeInterval animationDuration = 0.30f;
	[UIView beginAnimations:@"ResizeForKeyboard" context:nil];
	[UIView setAnimationDuration:animationDuration];
	float width = self.view.frame.size.width;
	float height = self.view.frame.size.height;
	CGRect rect = CGRectMake(0.0f, 0, width, height);
	_inputView.frame = rect;
	[UIView commitAnimations];
}

- (void)resetCountdown {
	static const int kRequestVerificationCodeCountdown = 60;
	_countdown = kRequestVerificationCodeCountdown;

	[_verificationCodeButton setEnabled:YES];
	[_verificationCodeTimer invalidate];
	[_verificationCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
}

- (void)showErrorMsg:(NSString *)msg {
	[_msgLabel setText:msg];
	[_msgView setHidden:NO];
	static const NSTimeInterval kErrorMsgTimeInterval = 10;
	[NSTimer scheduledTimerWithTimeInterval:kErrorMsgTimeInterval
											 target:self
										   selector:@selector(errorMsgTimerAction)
										   userInfo:nil
											repeats:NO];
}

- (void)checkResetButtonStatus {
	if ([_userNameTextField.text length] <= 0
		|| [_verificationCodeTextField.text length] <= 0
		|| [_firstPasswordTextField.text length] <= 0
		|| [_secondPasswordTextField.text length] <= 0) {
		[_resetButton setEnabled:NO];
	} else {
		[_resetButton setEnabled:YES];
	}
}

- (BOOL)checkPhoneNumber {
	NSString *str = _userNameTextField.text;
	if (str.length == 11
		&& [str rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]].location != NSNotFound) {
		return YES;
	}

	return NO;
}

- (BOOL)checkPasswordFormat {
	NSString *str1 = _firstPasswordTextField.text;
	NSString *str2 = _secondPasswordTextField.text;

	if (![str1 isEqualToString:str2]) {
		[self showErrorMsg:@"两次输入的密码不一致，请重新输入"];
		return NO;
	}

	static const long kMinPasswordLength = 6;
	if (str1.length < kMinPasswordLength) {
		[self showErrorMsg:[NSString stringWithFormat:@"密码长度不能少于%ld位", kMinPasswordLength]];
		return NO;
	}

	return YES;
}

# pragma mark - Timer Action

- (void)requestVerificationCodeTimerAction {
	_countdown--;
	if (_countdown > 0) {
		NSString *title = [[NSString alloc] initWithFormat:@"%ds 重新获取", _countdown];
		[_verificationCodeButton setTitle:title forState:UIControlStateNormal];
	} else {
		[self resetCountdown];
	}
}

- (void)errorMsgTimerAction {
	[_msgView setHidden:YES];
}

#pragma mark - button Actions

- (void)backButtonAction:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)resetButtonAction:(id)sender {
	if (![self checkPasswordFormat])
		return;

	MBProgressHUD *aMBProgressHUD = [MBProgressHUDHelp showLoadingWithText:@"正在提交注册"];
	NSString *passwordHash = [NSString md5HexDigest:_firstPasswordTextField.text];
	[MiaAPIHelper resetPasswordWithPhoneNum:_userNameTextField.text
							  passwordHash:passwordHash
									   scode:_verificationCodeTextField.text
	 completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
		 if (success) {
			 [HXAlertBanner showWithMessage:@"注册成功" tap:nil];
			 [self.navigationController popViewControllerAnimated:YES];
		 } else {
			 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
			 [self showErrorMsg:[NSString stringWithFormat:@"重置密码失败：%@", error]];
		 }

		 [aMBProgressHUD removeFromSuperview];
	 } timeoutBlock:^(MiaRequestItem *requestItem) {
		 [aMBProgressHUD removeFromSuperview];
		 [HXAlertBanner showWithMessage:@"注册失败，网络请求超时" tap:nil];
	 }];
}

- (void)verificationCodeButtonAction:(id)sender {
	if (![self checkPhoneNumber]) {
		[self showErrorMsg:@"请输入正确的手机号码"];
		return;
	}

	[_msgView setHidden:YES];
	[_verificationCodeButton setEnabled:NO];

	static const NSTimeInterval kRequestVerificationCodeTimeInterval = 1;
	_verificationCodeTimer = [NSTimer scheduledTimerWithTimeInterval:kRequestVerificationCodeTimeInterval
											 target:self
										   selector:@selector(requestVerificationCodeTimerAction)
										   userInfo:nil
											repeats:YES];
	[MiaAPIHelper getVerificationCodeWithType:1
								  phoneNumber:_userNameTextField.text
	 completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
		 if (success) {
			 [self showErrorMsg:@"验证码已经发送"];
		 } else {
			 [self showErrorMsg:@"验证码发送失败，请重新获取"];
			 [self resetCountdown];
		 }
	 } timeoutBlock:^(MiaRequestItem *requestItem) {
		 [self showErrorMsg:@"验证码发送失败，请重新获取"];
		 [self resetCountdown];
	 }];
}

- (void)hidenKeyboard {
	[_userNameTextField resignFirstResponder];
	[_verificationCodeTextField resignFirstResponder];
	[_firstPasswordTextField resignFirstResponder];
	[_secondPasswordTextField resignFirstResponder];

	[self resumeView];
	[self checkResetButtonStatus];
}

@end
