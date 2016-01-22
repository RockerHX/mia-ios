//
//  SignUpViewController.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "SignUpViewController.h"
#import "MIAButton.h"
#import "MBProgressHUDHelp.h"
#import "UIImage+Extrude.h"
#import "UIImage+ColorToImage.h"
#import "MiaAPIHelper.h"
#import "WebSocketMgr.h"
#import "NSString+MD5.h"
#import "TTTAttributedLabel.h"
#import "Masonry.h"
#import "HXAlertBanner.h"

@interface SignUpViewController () <UITextFieldDelegate, TTTAttributedLabelDelegate>

@end

@implementation SignUpViewController {
	UIView 			*_inputView;
	UITextField 	*_userNameTextField;
	UITextField 	*_verificationCodeTextField;
	UITextField 	*_nickNameTextField;
	UITextField 	*_firstPasswordTextField;
	UITextField 	*_secondPasswordTextField;
	MIAButton 		*_signUpButton;
	MIAButton 		*_verificationCodeButton;

	NSTimer 		*_verificationCodeTimer;
	int 			_countdown;

	MBProgressHUD 	*_progressHUD;
}

-(void)dealloc {
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
	[self initUI];
}

- (void)initUI {
	static NSString *kSignUpTitle = @"注册";
	self.title = kSignUpTitle;
	NSDictionary *fontDictionary = @{NSForegroundColorAttributeName:[UIColor blackColor],
								  NSFontAttributeName:UIFontFromSize(16)};
	[self.navigationController.navigationBar setTitleTextAttributes:fontDictionary];

	[self.view setBackgroundColor:[UIColor whiteColor]];
    
	[self initInputView];
	[self initBottomView];

	[_userNameTextField becomeFirstResponder];
}

- (void)initInputView {
	_inputView = [[UIView alloc] initWithFrame:self.view.frame];
	[self.view addSubview:_inputView];

	static const CGFloat kTextFieldMarginLeft		= 18;
	static const CGFloat kTextFieldHeight			= 45;
	static const CGFloat kUserNameMarginTop			= 25;
	static const CGFloat kVerificationCodeMarginTop	= kUserNameMarginTop + kTextFieldHeight + 5;
	static const CGFloat kNickNameMarginTop			= kVerificationCodeMarginTop + kTextFieldHeight + 5;
	static const CGFloat kFirstPasswordMarginTop	= kNickNameMarginTop + kTextFieldHeight + 5;
	static const CGFloat kSecondPasswordMarginTop	= kFirstPasswordMarginTop + kTextFieldHeight + 5;
	static const CGFloat kSiginUpMarginTop			= kSecondPasswordMarginTop + kTextFieldHeight + 38;
	static const CGFloat kSignUpMarginLeft			= 16;

	static const CGFloat kVerificationCodeButtonWidth			= 87;
	static const CGFloat kVerificationCodeButtonHeight			= 28;

	UIColor *placeHolderColor = UIColorFromHex(@"#808080", 1.0);
	UIColor *textColor = [UIColor blackColor];
	UIColor *lineColor = UIColorFromHex(@"#dcdcdc", 1.0);
	UIFont *textFont = UIFontFromSize(16);

	_userNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																	  kUserNameMarginTop,
																	  self.view.frame.size.width - 2 * kTextFieldMarginLeft,
																	  kTextFieldHeight)];
	_userNameTextField.borderStyle = UITextBorderStyleNone;
	_userNameTextField.backgroundColor = [UIColor clearColor];
	_userNameTextField.textColor = textColor;
	_userNameTextField.placeholder = @"输入手机号";
	[_userNameTextField setFont:textFont];
	_userNameTextField.keyboardType = UIKeyboardTypePhonePad;
	_userNameTextField.returnKeyType = UIReturnKeyNext;
	_userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
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
											 _verificationCodeTextField.frame.origin.y + _verificationCodeTextField.frame.size.height / 2 - kVerificationCodeButtonHeight / 2 - 2,
											 kVerificationCodeButtonWidth,
											 kVerificationCodeButtonHeight);
	_verificationCodeButton = [[MIAButton alloc] initWithFrame:verificationCodeButtonFrame
															   titleString:@"获取验证码"
																titleColor:[UIColor whiteColor]
																	  font:UIFontFromSize(14)
																   logoImg:nil
														   backgroundImage:[UIImage createImageWithColor:UIColorFromHex(@"ff5959", 1.0)]];
	[_verificationCodeButton setBackgroundImage:[UIImage createImageWithColor:UIColorFromHex(@"ff5959", 1.0)] forState:UIControlStateDisabled];
	[_verificationCodeButton addTarget:self action:@selector(verificationCodeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[_inputView addSubview:_verificationCodeButton];
	[self resetCountdown];

	_nickNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																	  kNickNameMarginTop,
																	  _inputView.frame.size.width - 2 * kTextFieldMarginLeft,
																	  kTextFieldHeight)];
	_nickNameTextField.borderStyle = UITextBorderStyleNone;
	_nickNameTextField.backgroundColor = [UIColor clearColor];
	_nickNameTextField.textColor = textColor;
	_nickNameTextField.placeholder = @"昵称";
	[_nickNameTextField setFont:textFont];
	_nickNameTextField.keyboardType = UIKeyboardTypeDefault;
	_nickNameTextField.returnKeyType = UIReturnKeyNext;
	_nickNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	_nickNameTextField.delegate = self;
	[_nickNameTextField setValue:placeHolderColor forKeyPath:@"_placeholderLabel.textColor"];
	[_inputView addSubview:_nickNameTextField];

	UIView *nickNameLineView = [[UIView alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																		kNickNameMarginTop + kTextFieldHeight,
																		_inputView.frame.size.width - 2 * kTextFieldMarginLeft,
																		0.5)];
	nickNameLineView.backgroundColor = lineColor;
	[_inputView addSubview:nickNameLineView];

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
	_firstPasswordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
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
	_secondPasswordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	_secondPasswordTextField.delegate = self;
	[_secondPasswordTextField setValue:placeHolderColor forKeyPath:@"_placeholderLabel.textColor"];
	[_inputView addSubview:_secondPasswordTextField];

	UIView *secondPasswordLineView = [[UIView alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																			  kSecondPasswordMarginTop + kTextFieldHeight,
																			  _inputView.frame.size.width - 2 * kTextFieldMarginLeft,
																			  0.5)];
	secondPasswordLineView.backgroundColor = lineColor;
	[_inputView addSubview:secondPasswordLineView];

	CGRect signUpButtonFrame = CGRectMake(kSignUpMarginLeft,
											 kSiginUpMarginTop,
											 _inputView.frame.size.width - 2 * kSignUpMarginLeft,
											 kTextFieldHeight);
	 _signUpButton = [[MIAButton alloc] initWithFrame:signUpButtonFrame
													   titleString:@"注册"
														titleColor:[UIColor whiteColor]
															  font:UIFontFromSize(16)
														   logoImg:nil
												   backgroundImage:[UIImage createImageWithColor:UIColorFromHex(@"000000", 1.0)]];
	[_signUpButton setBackgroundImage:[UIImage createImageWithColor:UIColorFromHex(@"f2f2f2", 1.0)] forState:UIControlStateDisabled];
	[_signUpButton setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
	[_signUpButton addTarget:self action:@selector(signUpButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[_signUpButton setEnabled:NO];
	_signUpButton.layer.cornerRadius = 23;
	_signUpButton.clipsToBounds = YES;

	[_inputView addSubview:_signUpButton];

	UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
	gesture.numberOfTapsRequired = 1;
	[_inputView addGestureRecognizer:gesture];
}

- (void)initBottomView {
	TTTAttributedLabel *bottomLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
	//bottomLabel.backgroundColor = [UIColor redColor];
	bottomLabel.font = UIFontFromSize(10.0f);
	bottomLabel.textColor = [UIColor grayColor];
	bottomLabel.numberOfLines = 0;
	bottomLabel.delegate = self;

	// If you're using a simple `NSString` for your text,
	// assign to the `text` property last so it can inherit other label properties.
	NSString *text = @"说明：\n1、注册时你将收到验证短信。Mia绝不会在任何途径泄露你的手机号码和个人信息。\n2、注册代表你已阅读并同意《Mia音乐软件使用协议》。";
	[bottomLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:
	 ^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
		 NSRange boldRange = [[mutableAttributedString string] rangeOfString:@"说明" options:NSCaseInsensitiveSearch];

		 // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
		 UIFont *boldSystemFont = [UIFont boldSystemFontOfSize:11];
		 CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
		 if (font) {
			 [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange];
			 CFRelease(font);
		 }

		 return mutableAttributedString;
	}];

	NSRange linkRange = [text rangeOfString:(@"《Mia音乐软件使用协议》")];
	[bottomLabel addLinkToURL:[NSURL URLWithString:@""] withRange:linkRange];

	[self.view addSubview:bottomLabel];
	[bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.bottom.equalTo(self.view.mas_bottom).offset(-50);
		make.left.equalTo(self.view.mas_left).offset(30);
		make.right.equalTo(self.view.mas_right).offset(-30);
	}];
}

#pragma mark - delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == _userNameTextField) {
		[_verificationCodeTextField becomeFirstResponder];
	} else if (textField == _verificationCodeTextField) {
		[_nickNameTextField becomeFirstResponder];
	} else if (textField == _nickNameTextField) {
		[_firstPasswordTextField becomeFirstResponder];
	} else if (textField == _firstPasswordTextField) {
		[_secondPasswordTextField becomeFirstResponder];
	} else if (textField == _secondPasswordTextField) {
		[_secondPasswordTextField resignFirstResponder];
		[self resumeView];
	}

	[self checkSignUpButtonStatus];

	return true;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	if (textField == _secondPasswordTextField) {
		[self moveUpViewForKeyboard];
	}

	return YES;
}

#pragma mark - TTTAttributedLabelDelegate Methods
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
	UIViewController *viewController = [[UIStoryboard storyboardWithName:@"Setting" bundle:nil] instantiateViewControllerWithIdentifier:@"HXUserTermsViewController"];
	[self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - Notification

#pragma mark - keyboard

- (void)moveUpViewForKeyboard {
	NSTimeInterval animationDuration = 0.30f;
	[UIView beginAnimations:@"ResizeForKeyboard" context:nil];
	[UIView setAnimationDuration:animationDuration];
	float width = _inputView.frame.size.width;
	float height = _inputView.frame.size.height;

	static const CGFloat kOffsetForKeyboard = 80;
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

- (void)checkSignUpButtonStatus {
	if ([_userNameTextField.text length] <= 0
	|| [_verificationCodeTextField.text length] <= 0
	|| [_nickNameTextField.text length] <= 0
	|| [_firstPasswordTextField.text length] <= 0
		|| [_secondPasswordTextField.text length] <= 0) {
		[_signUpButton setEnabled:NO];
	} else {
		[_signUpButton setEnabled:YES];
	}
}

- (BOOL)checkPhoneNumber {
	NSString *str = _userNameTextField.text;
	if (str.length == 11
		&& [str rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]].location != NSNotFound) {
		return YES;
	}

	[HXAlertBanner showWithMessage:@"手机号码不符合规范，请重新输入" tap:nil];

	return NO;
}

- (BOOL)checkPasswordFormat {
	NSString *str1 = _firstPasswordTextField.text;
	NSString *str2 = _secondPasswordTextField.text;

	if (![str1 isEqualToString:str2]) {
		[HXAlertBanner showWithMessage:@"两次输入的密码不一致，请重新输入" tap:nil];
		return NO;
	}

	static const long kMinPasswordLength = 6;
	if (str1.length < kMinPasswordLength) {
		[HXAlertBanner showWithMessage:[NSString stringWithFormat:@"密码长度不能少于%ld位", kMinPasswordLength] tap:nil];
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

#pragma mark - button Actions
- (void)signUpButtonAction:(id)sender {
	if (![self checkPasswordFormat])
		return;

	MBProgressHUD *aMBProgressHUD = [MBProgressHUDHelp showLoadingWithText:@"正在提交注册"];
	NSString *passwordHash = [NSString md5HexDigest:_firstPasswordTextField.text];
	[MiaAPIHelper registerWithPhoneNum:_userNameTextField.text
									 scode:_verificationCodeTextField.text
								  nickName:_nickNameTextField.text
								  passwordHash:passwordHash
	 completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
		 if (success) {
			 [_signUpViewControllerDelegate signUpViewControllerDidSuccess];
			 [HXAlertBanner showWithMessage:@"注册成功" tap:nil];
			 [self.navigationController popViewControllerAnimated:YES];
		 } else {
			 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
			 [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
		 }

		 [aMBProgressHUD removeFromSuperview];
	 } timeoutBlock:^(MiaRequestItem *requestItem) {
		 [aMBProgressHUD removeFromSuperview];
		 [HXAlertBanner showWithMessage:@"注册失败，网络请求超时" tap:nil];
	 }];
}

- (void)verificationCodeButtonAction:(id)sender {
	if (![self checkPhoneNumber]) {
		return;
	}

	[_verificationCodeButton setEnabled:NO];

	static const NSTimeInterval kRequestVerificationCodeTimeInterval = 1;
	_verificationCodeTimer = [NSTimer scheduledTimerWithTimeInterval:kRequestVerificationCodeTimeInterval
											 target:self
										   selector:@selector(requestVerificationCodeTimerAction)
										   userInfo:nil
											repeats:YES];

	[MiaAPIHelper getVerificationCodeWithType:0
								  phoneNumber:_userNameTextField.text
	 completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
		 if (success) {
			 [HXAlertBanner showWithMessage:@"验证码已经发送" tap:nil];
		 } else {
			 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
			 [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
			 [self resetCountdown];
		 }
	 } timeoutBlock:^(MiaRequestItem *requestItem) {
		 [HXAlertBanner showWithMessage:@"验证码发送超时，请重新获取" tap:nil];
		 [self resetCountdown];
	 }];
}

- (void)hidenKeyboard {
	[_userNameTextField resignFirstResponder];
	[_verificationCodeTextField resignFirstResponder];
	[_nickNameTextField resignFirstResponder];
	[_firstPasswordTextField resignFirstResponder];
	[_secondPasswordTextField resignFirstResponder];

	[self resumeView];
	[self checkSignUpButtonStatus];
}

@end
