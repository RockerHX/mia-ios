//
//  SignUpViewController.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "SignUpViewController.h"
#import "MIAButton.h"
#import "UIImage+Extrude.h"
#import "UIImage+ColorToImage.h"

@interface SignUpViewController () <UITextFieldDelegate>

@end

@implementation SignUpViewController {
	UITextField *userNameTextField;
	UITextField *verificationCodeTextField;
	UITextField *nickNameTextField;
	UITextField *firstPasswordTextField;
	UITextField *secondPasswordTextField;
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
	UIView *inputView = [[UIView alloc] initWithFrame:self.view.frame];
	[self.view addSubview:inputView];

	static const CGFloat kTextFieldMarginLeft		= 30;
	static const CGFloat kTextFieldHeight			= 35;
	static const CGFloat kUserNameMarginTop			= 100;
	static const CGFloat kVerificationCodeMarginTop	= kUserNameMarginTop + kTextFieldHeight + 5;
	static const CGFloat kNickNameMarginTop			= kVerificationCodeMarginTop + kTextFieldHeight + 5;
	static const CGFloat kFirstPasswordMarginTop	= kNickNameMarginTop + kTextFieldHeight + 5;
	static const CGFloat kSecondPasswordMarginTop	= kFirstPasswordMarginTop + kTextFieldHeight + 5;
	static const CGFloat kSiginUpMarginTop			= kSecondPasswordMarginTop + kTextFieldHeight + 45;

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

	nickNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																	  kNickNameMarginTop,
																	  inputView.frame.size.width - 2 * kTextFieldMarginLeft,
																	  kTextFieldHeight)];
	nickNameTextField.borderStyle = UITextBorderStyleNone;
	nickNameTextField.backgroundColor = [UIColor clearColor];
	nickNameTextField.textColor = textColor;
	nickNameTextField.placeholder = @"昵称";
	[nickNameTextField setFont:textFont];
	nickNameTextField.keyboardType = UIKeyboardTypeNumberPad;
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
	firstPasswordTextField.keyboardType = UIKeyboardTypeNumberPad;
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
	secondPasswordTextField.keyboardType = UIKeyboardTypeNumberPad;
	secondPasswordTextField.returnKeyType = UIReturnKeyNext;
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
	 MIAButton *signUpButton = [[MIAButton alloc] initWithFrame:signUpButtonFrame
													   titleString:@"注册"
														titleColor:[UIColor blackColor]
															  font:UIFontFromSize(16)
														   logoImg:nil
												   backgroundImage:[UIImage createImageWithColor:UIColorFromHex(@"f2f2f2", 1.0)]];
	 [signUpButton addTarget:self action:@selector(signUpButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	 [inputView addSubview:signUpButton];
}

#pragma mark - delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
/*
	if (textField == userNameTextField) {
		[passwordTextField becomeFirstResponder];
	}
	else if (textField == passwordTextField) {
		[passwordTextField resignFirstResponder];
	}
*/
	return true;
}



#pragma mark - button Actions

- (void)backButtonAction:(id)sender {
	NSLog(@"back button clicked.");
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)signUpButtonAction:(id)sender {
}

@end
