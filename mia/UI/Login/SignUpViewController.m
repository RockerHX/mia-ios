//
//  SignUpViewController.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "SignUpViewController.h"
#import "MIAButton.h"
#import "MIALabel.h"
#import "UIImage+Extrude.h"
#import "UIImage+ColorToImage.h"
#import "MiaAPIHelper.h"

@interface SignUpViewController () <UITextFieldDelegate>

@end

@implementation SignUpViewController {
	UIView *inputView;
	UITextField *userNameTextField;
	UITextField *verificationCodeTextField;
	UITextField *nickNameTextField;
	UITextField *firstPasswordTextField;
	UITextField *secondPasswordTextField;
	MIAButton *signUpButton;
	MIAButton *verificationCodeButton;

	UIView *msgView;
	MIALabel *msgLabel;

	NSTimer *timer;
	int countdown;
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
	static NSString *kSignUpTitle = @"注册";
	self.title = kSignUpTitle;
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
	inputView = [[UIView alloc] initWithFrame:self.view.frame];
	[self.view addSubview:inputView];

	static const CGFloat kTextFieldMarginLeft		= 30;
	static const CGFloat kTextFieldHeight			= 35;
	static const CGFloat kUserNameMarginTop			= 100;
	static const CGFloat kVerificationCodeMarginTop	= kUserNameMarginTop + kTextFieldHeight + 5;
	static const CGFloat kNickNameMarginTop			= kVerificationCodeMarginTop + kTextFieldHeight + 5;
	static const CGFloat kFirstPasswordMarginTop	= kNickNameMarginTop + kTextFieldHeight + 5;
	static const CGFloat kSecondPasswordMarginTop	= kFirstPasswordMarginTop + kTextFieldHeight + 5;
	static const CGFloat kSiginUpMarginTop			= kSecondPasswordMarginTop + kTextFieldHeight + 45;

	static const CGFloat kVerificationCodeButtonWidthMarginTop	= kVerificationCodeMarginTop + 5;
 	static const CGFloat kVerificationCodeButtonWidth			= 80;
	static const CGFloat kVerificationCodeButtonHeight			= 25;

	UIColor *placeHolderColor = UIColorFromHex(@"#c0c0c0", 1.0);
	UIColor *textColor = [UIColor blackColor];
	UIColor *lineColor = UIColorFromHex(@"#eaeaea", 1.0);
	UIFont *textFont = UIFontFromSize(12);

	userNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																	  kUserNameMarginTop,
																	  self.view.frame.size.width - 2 * kTextFieldMarginLeft,
																	  kTextFieldHeight)];
	userNameTextField.borderStyle = UITextBorderStyleNone;
	userNameTextField.backgroundColor = [UIColor clearColor];
	userNameTextField.textColor = textColor;
	userNameTextField.placeholder = @"输入手机号";
	[userNameTextField setFont:textFont];
	userNameTextField.keyboardType = UIKeyboardTypeNumberPad;
	userNameTextField.returnKeyType = UIReturnKeyNext;
	userNameTextField.delegate = self;
	[userNameTextField setValue:placeHolderColor forKeyPath:@"_placeholderLabel.textColor"];
	[inputView addSubview:userNameTextField];

	UIView *userNameLineView = [[UIView alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																		kUserNameMarginTop + kTextFieldHeight,
																		inputView.frame.size.width - 2 * kTextFieldMarginLeft,
																		0.5)];
	userNameLineView.backgroundColor = lineColor;
	[inputView addSubview:userNameLineView];

	verificationCodeTextField = [[UITextField alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																			  kVerificationCodeMarginTop,
																			  inputView.frame.size.width - 2 * kTextFieldMarginLeft,
																			  kTextFieldHeight)];
	verificationCodeTextField.borderStyle = UITextBorderStyleNone;
	verificationCodeTextField.backgroundColor = [UIColor clearColor];
	verificationCodeTextField.textColor = textColor;
	verificationCodeTextField.placeholder = @"验证码";
	[verificationCodeTextField setFont:textFont];
	verificationCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
	verificationCodeTextField.returnKeyType = UIReturnKeyNext;
	verificationCodeTextField.delegate = self;
	[verificationCodeTextField setValue:placeHolderColor forKeyPath:@"_placeholderLabel.textColor"];
	[inputView addSubview:verificationCodeTextField];

	UIView *verificationCodeLineView = [[UIView alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																				kVerificationCodeMarginTop + kTextFieldHeight,
																				inputView.frame.size.width - 2 * kTextFieldMarginLeft,
																				0.5)];
	verificationCodeLineView.backgroundColor = lineColor;
	[inputView addSubview:verificationCodeLineView];

	CGRect verificationCodeButtonFrame = CGRectMake(inputView.frame.size.width - kTextFieldMarginLeft - kVerificationCodeButtonWidth,
											 kVerificationCodeButtonWidthMarginTop,
											 kVerificationCodeButtonWidth,
											 kVerificationCodeButtonHeight);
	verificationCodeButton = [[MIAButton alloc] initWithFrame:verificationCodeButtonFrame
															   titleString:@"获取验证码"
																titleColor:[UIColor whiteColor]
																	  font:textFont
																   logoImg:nil
														   backgroundImage:[UIImage createImageWithColor:UIColorFromHex(@"ff5959", 1.0)]];
	[verificationCodeButton setBackgroundImage:[UIImage createImageWithColor:UIColorFromHex(@"ff5959", 1.0)] forState:UIControlStateDisabled];
	[verificationCodeButton addTarget:self action:@selector(verificationCodeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[inputView addSubview:verificationCodeButton];
	[self resetCountdown];

	nickNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																	  kNickNameMarginTop,
																	  inputView.frame.size.width - 2 * kTextFieldMarginLeft,
																	  kTextFieldHeight)];
	nickNameTextField.borderStyle = UITextBorderStyleNone;
	nickNameTextField.backgroundColor = [UIColor clearColor];
	nickNameTextField.textColor = textColor;
	nickNameTextField.placeholder = @"昵称";
	[nickNameTextField setFont:textFont];
	nickNameTextField.keyboardType = UIKeyboardTypeDefault;
	nickNameTextField.returnKeyType = UIReturnKeyNext;
	nickNameTextField.delegate = self;
	[nickNameTextField setValue:placeHolderColor forKeyPath:@"_placeholderLabel.textColor"];
	[inputView addSubview:nickNameTextField];

	UIView *nickNameLineView = [[UIView alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																		kNickNameMarginTop + kTextFieldHeight,
																		inputView.frame.size.width - 2 * kTextFieldMarginLeft,
																		0.5)];
	nickNameLineView.backgroundColor = lineColor;
	[inputView addSubview:nickNameLineView];

	firstPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																		   kFirstPasswordMarginTop,
																		   inputView.frame.size.width - 2 * kTextFieldMarginLeft,
																		   kTextFieldHeight)];
	firstPasswordTextField.borderStyle = UITextBorderStyleNone;
	firstPasswordTextField.backgroundColor = [UIColor clearColor];
	firstPasswordTextField.textColor = textColor;
	firstPasswordTextField.placeholder = @"登录密码";
	[firstPasswordTextField setFont:textFont];
	firstPasswordTextField.secureTextEntry = YES;
	firstPasswordTextField.keyboardType = UIKeyboardTypeDefault;
	firstPasswordTextField.returnKeyType = UIReturnKeyNext;
	firstPasswordTextField.delegate = self;
	[firstPasswordTextField setValue:placeHolderColor forKeyPath:@"_placeholderLabel.textColor"];
	[inputView addSubview:firstPasswordTextField];

	UIView *firstPasswordLineView = [[UIView alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																			 kFirstPasswordMarginTop + kTextFieldHeight,
																			 inputView.frame.size.width - 2 * kTextFieldMarginLeft,
																			 0.5)];
	firstPasswordLineView.backgroundColor = lineColor;
	[inputView addSubview:firstPasswordLineView];

	secondPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																	  kSecondPasswordMarginTop,
																	  inputView.frame.size.width - 2 * kTextFieldMarginLeft,
																	  kTextFieldHeight)];
	secondPasswordTextField.borderStyle = UITextBorderStyleNone;
	secondPasswordTextField.backgroundColor = [UIColor clearColor];
	secondPasswordTextField.textColor = textColor;
	secondPasswordTextField.placeholder = @"确认密码";
	[secondPasswordTextField setFont:textFont];
	secondPasswordTextField.secureTextEntry = YES;
	secondPasswordTextField.keyboardType = UIKeyboardTypeDefault;
	secondPasswordTextField.returnKeyType = UIReturnKeyDone;
	secondPasswordTextField.delegate = self;
	[secondPasswordTextField setValue:placeHolderColor forKeyPath:@"_placeholderLabel.textColor"];
	[inputView addSubview:secondPasswordTextField];

	UIView *secondPasswordLineView = [[UIView alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																			  kSecondPasswordMarginTop + kTextFieldHeight,
																			  inputView.frame.size.width - 2 * kTextFieldMarginLeft,
																			  0.5)];
	secondPasswordLineView.backgroundColor = lineColor;
	[inputView addSubview:secondPasswordLineView];

	CGRect signUpButtonFrame = CGRectMake(kTextFieldMarginLeft,
											 kSiginUpMarginTop,
											 inputView.frame.size.width - 2 * kTextFieldMarginLeft,
											 kTextFieldHeight);
	 signUpButton = [[MIAButton alloc] initWithFrame:signUpButtonFrame
													   titleString:@"注册"
														titleColor:[UIColor whiteColor]
															  font:UIFontFromSize(16)
														   logoImg:nil
												   backgroundImage:[UIImage createImageWithColor:UIColorFromHex(@"000000", 1.0)]];
	[signUpButton setBackgroundImage:[UIImage createImageWithColor:UIColorFromHex(@"f2f2f2", 1.0)] forState:UIControlStateDisabled];
	[signUpButton setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
	[signUpButton addTarget:self action:@selector(signUpButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[signUpButton setEnabled:NO];
	[inputView addSubview:signUpButton];

	UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
	gesture.numberOfTapsRequired = 1;
	[inputView addGestureRecognizer:gesture];
}

- (void)initMsgView {
	static const CGFloat kMsgViewMarginTop = 64;
	static const CGFloat kMsgViewHeight = 35;
	static const CGFloat kLogoMarginLeft = 10;
	static const CGFloat kLogoMarginTop = 10;
	static const CGFloat kLogoWidth = 18;
	static const CGFloat kLogoHeight = 18;
	static const CGFloat kMsgLabelMarginLeft = 30;
	static const CGFloat kMsgLabelMarginRight = 15;
	static const CGFloat kMsgLabelMarginTop = 8;
	static const CGFloat kMsgLabelHeight = 20;


	msgView = [[UIView alloc] initWithFrame:CGRectMake(0, kMsgViewMarginTop, self.view.frame.size.width, kMsgViewHeight)];
	msgView.backgroundColor = UIColorFromHex(@"#606060", 1.0);
	[self.view addSubview:msgView];


	UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kLogoMarginLeft, kLogoMarginTop, kLogoWidth, kLogoHeight)];
	[logoImageView setImage:[UIImage imageNamed:@"comments"]];
	[msgView addSubview:logoImageView];

	msgLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kMsgLabelMarginLeft,
															  kMsgLabelMarginTop,
															  msgView.frame.size.width - kMsgLabelMarginLeft - kMsgLabelMarginRight,
															  kMsgLabelHeight)
											  text:@""
											  font:UIFontFromSize(12.0f)
										 textColor:[UIColor whiteColor]
									 textAlignment:NSTextAlignmentLeft
									   numberLines:1];
	[msgView addSubview:msgLabel];
	[msgView setHidden:YES];
}

#pragma mark - delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == userNameTextField) {
		[verificationCodeTextField becomeFirstResponder];
	}
	else if (textField == verificationCodeTextField) {
		[nickNameTextField becomeFirstResponder];
	} else if (textField == nickNameTextField) {
		[firstPasswordTextField becomeFirstResponder];
	} else if (textField == firstPasswordTextField) {
		[secondPasswordTextField becomeFirstResponder];
	} else if (textField == secondPasswordTextField) {
		[secondPasswordTextField resignFirstResponder];
		[self resumeView];
	}

	[self checkSignUpButtonStatus];

	return true;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	if (textField == secondPasswordTextField) {
		[self moveUpViewForKeyboard];
	}

	return YES;
}

#pragma mark - keyboard

- (void)moveUpViewForKeyboard {
	NSTimeInterval animationDuration = 0.30f;
	[UIView beginAnimations:@"ResizeForKeyboard" context:nil];
	[UIView setAnimationDuration:animationDuration];
	float width = inputView.frame.size.width;
	float height = inputView.frame.size.height;

	static const CGFloat kOffsetForKeyboard = 30;
	CGRect rect = CGRectMake(0.0f, -kOffsetForKeyboard, width,height);
	inputView.frame = rect;
	[UIView commitAnimations];
}

- (void)resumeView {
	NSTimeInterval animationDuration = 0.30f;
	[UIView beginAnimations:@"ResizeForKeyboard" context:nil];
	[UIView setAnimationDuration:animationDuration];
	float width = self.view.frame.size.width;
	float height = self.view.frame.size.height;
	CGRect rect = CGRectMake(0.0f, 0, width, height);
	inputView.frame = rect;
	[UIView commitAnimations];
}

- (void)resetCountdown {
	static const int kRequestVerificationCodeCountdown = 60;
	countdown = kRequestVerificationCodeCountdown;

	[verificationCodeButton setEnabled:YES];
	[timer invalidate];
	[verificationCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
}

- (void)showErrorMsg:(NSString *)msg {
	[msgLabel setText:msg];
	[msgView setHidden:NO];
	static const NSTimeInterval kErrorMsgTimeInterval = 10;
	timer = [NSTimer scheduledTimerWithTimeInterval:kErrorMsgTimeInterval
											 target:self
										   selector:@selector(errorMsgTimerAction)
										   userInfo:nil
											repeats:NO];
}

- (void)checkSignUpButtonStatus {
	if ([userNameTextField.text length] <= 0
	|| [verificationCodeTextField.text length] <= 0
	|| [nickNameTextField.text length] <= 0
	|| [firstPasswordTextField.text length] <= 0
		|| [secondPasswordTextField.text length] <= 0) {
		[signUpButton setEnabled:NO];
	} else {
		[signUpButton setEnabled:YES];
	}
}

- (BOOL)checkPhoneNumber {
	NSString *str = userNameTextField.text;
	if (str.length == 11
		&& [str rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]].location != NSNotFound) {
		return YES;
	}

	return NO;
}

# pragma mark - Timer Action

- (void)requestVerificationCodeTimerAction {
	countdown--;
	if (countdown > 0) {
		NSString *title = [[NSString alloc] initWithFormat:@"%ds 重新获取", countdown];
		[verificationCodeButton setTitle:title forState:UIControlStateNormal];
	} else {
		[self resetCountdown];
	}
}

- (void)errorMsgTimerAction {
	[msgView setHidden:YES];
}

#pragma mark - button Actions

- (void)backButtonAction:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)signUpButtonAction:(id)sender {
	// for test
	//[self showErrorMsg:@"Opps!你输入的验证码错误，请重新获取验证码"];

}

- (void)verificationCodeButtonAction:(id)sender {
	if (![self checkPhoneNumber]) {
		[self showErrorMsg:@"请输入正确的手机号码"];
		return;
	}

	[msgView setHidden:YES];
	[verificationCodeButton setEnabled:NO];

	static const NSTimeInterval kRequestVerificationCodeTimeInterval = 1;
	timer = [NSTimer scheduledTimerWithTimeInterval:kRequestVerificationCodeTimeInterval
											 target:self
										   selector:@selector(requestVerificationCodeTimerAction)
										   userInfo:nil
											repeats:YES];

	[MiaAPIHelper getVerificationCodeWithType:0 phoneNumber:userNameTextField.text];
}

-(void)hidenKeyboard
{
	[userNameTextField resignFirstResponder];
	[verificationCodeTextField resignFirstResponder];
	[nickNameTextField resignFirstResponder];
	[firstPasswordTextField resignFirstResponder];
	[secondPasswordTextField resignFirstResponder];

	[self resumeView];
	[self checkSignUpButtonStatus];
}

@end
