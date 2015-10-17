//
//  ChangePwdViewController.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "ChangePwdViewController.h"
#import "MIAButton.h"
#import "MIALabel.h"
#import "UIImage+Extrude.h"
#import "UIImage+ColorToImage.h"
#import "MiaAPIHelper.h"
#import "WebSocketMgr.h"
#import "MBProgressHUD.h"
#import "MBProgressHUDHelp.h"
#import "NSString+MD5.h"

@interface ChangePwdViewController () <UITextFieldDelegate>

@end

@implementation ChangePwdViewController {
	UIView 			*_inputView;
	UITextField 	*_oldPasswordTextField;
	UITextField 	*_firstPasswordTextField;
	UITextField 	*_secondPasswordTextField;
	MIAButton 		*_confirmButton;

	UIView 			*_msgView;
	MIALabel 		*_msgLabel;

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
	return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
	return NO;
}

- (void)initUI {
	static NSString *kChangePwdTitle = @"修改密码";
	self.title = kChangePwdTitle;
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

	_oldPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																	  kUserNameMarginTop,
																	  self.view.frame.size.width - 2 * kTextFieldMarginLeft,
																	  kTextFieldHeight)];
	_oldPasswordTextField.borderStyle = UITextBorderStyleNone;
	_oldPasswordTextField.backgroundColor = [UIColor clearColor];
	_oldPasswordTextField.textColor = textColor;
	_oldPasswordTextField.placeholder = @"输入旧密码";
	[_oldPasswordTextField setFont:textFont];
	_oldPasswordTextField.secureTextEntry = YES;
	_oldPasswordTextField.keyboardType = UIKeyboardTypeDefault;
	_oldPasswordTextField.returnKeyType = UIReturnKeyNext;
	_oldPasswordTextField.delegate = self;
	[_oldPasswordTextField setValue:placeHolderColor forKeyPath:@"_placeholderLabel.textColor"];
	[_inputView addSubview:_oldPasswordTextField];

	UIView *userNameLineView = [[UIView alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																		kUserNameMarginTop + kTextFieldHeight,
																		_inputView.frame.size.width - 2 * kTextFieldMarginLeft,
																		0.5)];
	userNameLineView.backgroundColor = lineColor;
	[_inputView addSubview:userNameLineView];

	_firstPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																			  kVerificationCodeMarginTop,
																			  _inputView.frame.size.width - 2 * kTextFieldMarginLeft,
																			  kTextFieldHeight)];
	_firstPasswordTextField.borderStyle = UITextBorderStyleNone;
	_firstPasswordTextField.backgroundColor = [UIColor clearColor];
	_firstPasswordTextField.textColor = textColor;
	_firstPasswordTextField.placeholder = @"输入新密码";
	[_firstPasswordTextField setFont:textFont];
	_firstPasswordTextField.secureTextEntry = YES;
	_firstPasswordTextField.keyboardType = UIKeyboardTypeDefault;
	_firstPasswordTextField.returnKeyType = UIReturnKeyNext;
	_firstPasswordTextField.delegate = self;
	[_firstPasswordTextField setValue:placeHolderColor forKeyPath:@"_placeholderLabel.textColor"];
	[_inputView addSubview:_firstPasswordTextField];

	UIView *verificationCodeLineView = [[UIView alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																				kVerificationCodeMarginTop + kTextFieldHeight,
																				_inputView.frame.size.width - 2 * kTextFieldMarginLeft,
																				0.5)];
	verificationCodeLineView.backgroundColor = lineColor;
	[_inputView addSubview:verificationCodeLineView];

	_secondPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																		   kFirstPasswordMarginTop,
																		   _inputView.frame.size.width - 2 * kTextFieldMarginLeft,
																		   kTextFieldHeight)];
	_secondPasswordTextField.borderStyle = UITextBorderStyleNone;
	_secondPasswordTextField.backgroundColor = [UIColor clearColor];
	_secondPasswordTextField.textColor = textColor;
	_secondPasswordTextField.placeholder = @"再次输入新密码";
	[_secondPasswordTextField setFont:textFont];
	_secondPasswordTextField.secureTextEntry = YES;
	_secondPasswordTextField.keyboardType = UIKeyboardTypeDefault;
	_secondPasswordTextField.returnKeyType = UIReturnKeyNext;
	_secondPasswordTextField.delegate = self;
	[_secondPasswordTextField setValue:placeHolderColor forKeyPath:@"_placeholderLabel.textColor"];
	[_inputView addSubview:_secondPasswordTextField];

	UIView *firstPasswordLineView = [[UIView alloc] initWithFrame:CGRectMake(kTextFieldMarginLeft,
																			 kFirstPasswordMarginTop + kTextFieldHeight,
																			 _inputView.frame.size.width - 2 * kTextFieldMarginLeft,
																			 0.5)];
	firstPasswordLineView.backgroundColor = lineColor;
	[_inputView addSubview:firstPasswordLineView];

	CGRect resetButtonFrame = CGRectMake(kTextFieldMarginLeft,
											 kSiginUpMarginTop,
											 _inputView.frame.size.width - 2 * kTextFieldMarginLeft,
											 kTextFieldHeight);
	 _confirmButton = [[MIAButton alloc] initWithFrame:resetButtonFrame
													   titleString:@"修改密码"
														titleColor:[UIColor whiteColor]
															  font:UIFontFromSize(16)
														   logoImg:nil
												   backgroundImage:[UIImage createImageWithColor:UIColorFromHex(@"000000", 1.0)]];
	[_confirmButton setBackgroundImage:[UIImage createImageWithColor:UIColorFromHex(@"f2f2f2", 1.0)] forState:UIControlStateDisabled];
	[_confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
	[_confirmButton addTarget:self action:@selector(confirmButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[_confirmButton setEnabled:NO];
	[_inputView addSubview:_confirmButton];

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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == _oldPasswordTextField) {
		[_firstPasswordTextField becomeFirstResponder];
	} else if (textField == _firstPasswordTextField) {
		[_secondPasswordTextField becomeFirstResponder];
	} else if (textField == _secondPasswordTextField) {
		[_secondPasswordTextField resignFirstResponder];
		[self resumeView];
	}

	[self checkConfirmButtonStatus];
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

- (void)checkConfirmButtonStatus {
	if ([_oldPasswordTextField.text length] <= 0
		|| [_firstPasswordTextField.text length] <= 0
		|| [_secondPasswordTextField.text length] <= 0) {
		[_confirmButton setEnabled:NO];
	} else {
		[_confirmButton setEnabled:YES];
	}
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

- (void)errorMsgTimerAction {
	[_msgView setHidden:YES];
}

#pragma mark - button Actions

- (void)backButtonAction:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)confirmButtonAction:(id)sender {
	if (![self checkPasswordFormat])
		return;

	[self showMBProgressHUD];
	NSString *newPasswordHash = [NSString md5HexDigest:_firstPasswordTextField.text];
	NSString *oldPasswordHash = [NSString md5HexDigest:_oldPasswordTextField.text];
	// TODO changePwd
	NSString *userName = @"";
	[MiaAPIHelper resetPasswordWithPhoneNum:userName
							  passwordHash:newPasswordHash
									   scode:oldPasswordHash
	 completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
		 if (!success) {
			 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
			 [self showErrorMsg:[NSString stringWithFormat:@"重置密码失败：%@", error]];
		 }

		 [self removeMBProgressHUD:success removeMBProgressHUDBlock:^{
			 if (success) {
				 [self.navigationController popViewControllerAnimated:YES];
			 }
		 }];
	 } timeoutBlock:^(MiaRequestItem *requestItem) {
		 [self removeMBProgressHUD:NO removeMBProgressHUDBlock:nil];
	 }];
}

- (void)hidenKeyboard {
	[_oldPasswordTextField resignFirstResponder];
	[_firstPasswordTextField resignFirstResponder];
	[_secondPasswordTextField resignFirstResponder];

	[self resumeView];
	[self checkConfirmButtonStatus];
}

@end
