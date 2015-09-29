//
//  ShareViewController.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "ShareViewController.h"
#import "MIAButton.h"
#import "MIALabel.h"
#import "MBProgressHUD.h"
#import "MBProgressHUDHelp.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Extrude.h"
#import "CommentCollectionViewCell.h"
#import "DetailHeaderView.h"
#import "MiaAPIHelper.h"
#import "WebSocketMgr.h"

static const CGFloat kDetailHeaderHeight 		= 350;
static const CGFloat kDetailFooterViewHeight 	= 40;

@interface ShareViewController () <UITextFieldDelegate>

@end

@implementation ShareViewController {
	ShareItem *shareItem;

	UITextField *commentTextField;
	MIAButton *commentButton;

	DetailHeaderView *detailHeaderView;
	UIView *footerView;
	MBProgressHUD *progressHUD;

	MIAButton *sendButton;
}

- (id)init {
	self = [super init];
	if (self) {
		[self initUI];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidReceiveMessage:) name:WebSocketMgrNotificationDidReceiveMessage object:nil];

		//添加键盘监听
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	}

	return self;
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidReceiveMessage object:nil];

	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
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
	static NSString *kDetailTitle = @"分享";
	self.title = kDetailTitle;
	[self initBarButton];

	UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
	gesture.numberOfTapsRequired = 1;
	[self.view addGestureRecognizer:gesture];

	[self initHeaderView];
	[self initFooterView];
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

	const static CGFloat kSendButtonWidth		= 40;
	const static CGFloat kSendButtonHeight		= 20;

	sendButton = [[MIAButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kSendButtonWidth, kSendButtonHeight)
												 titleString:@"发送"
												  titleColor:UIColorFromHex(@"ff300e", 1.0)
														font:UIFontFromSize(15)
													 logoImg:nil
											 backgroundImage:nil];
	[sendButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
	rightButton.enabled = NO;
	self.navigationItem.rightBarButtonItem = rightButton;
	[sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initHeaderView {
	detailHeaderView = [[DetailHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kDetailHeaderHeight)];
	detailHeaderView.shareItem = shareItem;

	//NSLog(@"initHeaderView: %f, %f, %f, %f", contentView.bounds.origin.x, contentView.bounds.origin.y, contentView.bounds.size.width, contentView.bounds.size.height);
	//[contentView addSubview:detailHeaderView];
}

- (void)initFooterView {
	//footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kDetailFooterViewHeight)];
	footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - kDetailFooterViewHeight, self.view.bounds.size.width, kDetailFooterViewHeight)];
	footerView.backgroundColor = UIColorFromHex(@"d2d0d0", 1.0);
	[self.view addSubview:footerView];

	UIView *textBGView = [[UIView alloc] initWithFrame:CGRectInset(footerView.bounds, 1, 1)];
	textBGView.backgroundColor = UIColorFromHex(@"f2f2f2", 1.0);
	[footerView addSubview:textBGView];

	static const CGFloat kEditViewMarginLeft 		= 28;
	static const CGFloat kEditViewMarginRight 		= 70;
	static const CGFloat kEditViewMarginTop 		= 5;
	static const CGFloat kEditViewHeight			= 30;

	static const CGFloat kCommentButtonMarginRight 	= 15;
	static const CGFloat kCommentButtonMarginTop	= 10;
	static const CGFloat kCommentButtonWidth		= 50;
	static const CGFloat kCommentButtonHeight		= 20;

	commentTextField = [[UITextField alloc] initWithFrame:CGRectMake(kEditViewMarginLeft,
																				   kEditViewMarginTop,
																				   footerView.bounds.size.width - kEditViewMarginLeft - kEditViewMarginRight,
																				   kEditViewHeight)];
	commentTextField.borderStyle = UITextBorderStyleNone;
	commentTextField.backgroundColor = [UIColor clearColor];
	commentTextField.textColor = UIColorFromHex(@"#a2a2a2", 1.0);
	commentTextField.placeholder = @"说说此刻的想法";
	[commentTextField setFont:UIFontFromSize(16)];
	commentTextField.keyboardType = UIKeyboardTypeDefault;
	commentTextField.returnKeyType = UIReturnKeySend;
	commentTextField.delegate = self;
	//commentTextField.backgroundColor = [UIColor yellowColor];
	[commentTextField setValue:UIColorFromHex(@"#949494", 1.0) forKeyPath:@"_placeholderLabel.textColor"];
	[commentTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

	[footerView addSubview:commentTextField];


	commentButton = [[MIAButton alloc] initWithFrame:CGRectMake(footerView.frame.size.width - kCommentButtonMarginRight - kCommentButtonWidth,
																		   kCommentButtonMarginTop,
																		   kCommentButtonWidth,
																		   kCommentButtonHeight)
										 titleString:@"发送"
										  titleColor:UIColorFromHex(@"#ff300f", 1.0)
												font:UIFontFromSize(15)
											 logoImg:nil
									 backgroundImage:nil];
	[commentButton addTarget:self action:@selector(commentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[commentButton setTitleColor:UIColorFromHex(@"#a2a2a2", 1.0) forState:UIControlStateDisabled];
	[commentButton setEnabled:NO];
	//commentButton.backgroundColor = [UIColor redColor];
	[footerView addSubview:commentButton];
}

- (void)checkCommentButtonStatus {
	if ([commentTextField.text length] <= 0) {
		[commentButton setEnabled:NO];
	} else {
		[commentButton setEnabled:YES];
	}
}

- (void)showMBProgressHUD{
	if(!progressHUD){
		UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
		progressHUD = [[MBProgressHUD alloc] initWithView:window];
		[window addSubview:progressHUD];
		progressHUD.dimBackground = YES;
		progressHUD.labelText = @"正在提交评论";
		[progressHUD show:YES];
	}
}

- (void)removeMBProgressHUD:(BOOL)isSuccess removeMBProgressHUDBlock:(RemoveMBProgressHUDBlock)removeMBProgressHUDBlock{
	if(progressHUD){
		if(isSuccess){
			progressHUD.labelText = @"评论成功";
		}else{
			progressHUD.labelText = @"评论失败，请稍后再试";
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

#pragma mark - delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == commentTextField) {
		[textField resignFirstResponder];
	}

	return true;
}

- (void) textFieldDidChange:(id) sender {
	[self checkCommentButtonStatus];
}

#pragma mark - Notification

- (void)notificationWebSocketDidReceiveMessage:(NSNotification *)notification {
//	NSString *command = [notification userInfo][MiaAPIKey_ServerCommand];
//	id ret = [notification userInfo][MiaAPIKey_Values][MiaAPIKey_Return];
//	NSLog(@"%@", command);

//	if ([command isEqualToString:MiaAPICommand_Music_GetMcomm]) {
//		[self handleGetMusicCommentWitRet:[ret intValue] userInfo:[notification userInfo]];
//	}
}

//- (void)handlePostCommentWitRet:(int)ret userInfo:(NSDictionary *) userInfo {
//	BOOL isSuccess = (0 == ret);
//
//	if (isSuccess) {
//		commentTextField.text = @"";
//		[self requestLatestComments];
//	} else {
//	}
//
//	[self removeMBProgressHUD:isSuccess removeMBProgressHUDBlock:^{
//		if (isSuccess) {
//		}
//	}];
//}

/*
 *   即将显示键盘的处理
 */
- (void)keyBoardWillShow:(NSNotification *)notification{
	NSDictionary *info = [notification userInfo];
	//获取当前显示的键盘高度
	CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey ] CGRectValue].size;
	[self moveUpViewForKeyboard:keyboardSize];
}

- (void)keyBoardWillHide:(NSNotification *)notification{
	[self resumeView];
}

#pragma mark - keyboard

- (void)moveUpViewForKeyboard:(CGSize)keyboardSize {
	NSTimeInterval animationDuration = 0.30f;
	[UIView beginAnimations:@"ResizeForKeyboard" context:nil];
	[UIView setAnimationDuration:animationDuration];
//	float width = footerView.frame.size.width;
//	float height = footerView.frame.size.height;
//
//	CGRect rect = CGRectMake(0.0f, -keyboardSize.height, width,height);
	CGRect rect = CGRectMake(0, self.view.bounds.size.height - kDetailFooterViewHeight - keyboardSize.height, self.view.bounds.size.width, kDetailFooterViewHeight);
	footerView.frame = rect;
	[UIView commitAnimations];
}

- (void)resumeView {
	NSTimeInterval animationDuration = 0.30f;
	[UIView beginAnimations:@"ResizeForKeyboard" context:nil];
	[UIView setAnimationDuration:animationDuration];
//	float width = self.view.frame.size.width;
//	float height = self.view.frame.size.height;
	CGRect rect = CGRectMake(0, self.view.bounds.size.height - kDetailFooterViewHeight, self.view.bounds.size.width, kDetailFooterViewHeight);
	footerView.frame = rect;
	[UIView commitAnimations];
}

- (void)hidenKeyboard {
	[commentTextField resignFirstResponder];
	[self checkCommentButtonStatus];
}

#pragma mark - button Actions

- (void)backButtonAction:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)sendButtonAction:(id)sender {
	NSLog(@"send button clicked.");
}

- (void)commentButtonAction:(id)sender {
	NSLog(@"comment button clicked.");
	[self showMBProgressHUD];
	[MiaAPIHelper postCommentWithShareID:shareItem.sID comment:commentTextField.text];

}

@end
