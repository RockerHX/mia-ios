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
#import "MiaAPIHelper.h"
#import "MIAButton.h"

static const CGFloat kBackButtonMarginLeft		= 15;
static const CGFloat kBackButtonMarginTop		= 32;
static const CGFloat kLogoMarginTop				= 90;

static const CGFloat kGuidButtonHeight			= 40;
static const CGFloat kGuidButtonMarginLeft		= 30;
static const CGFloat kSignInMarginBottom		= 50;
static const CGFloat kSignUpMarginBottom		= kSignInMarginBottom + kGuidButtonHeight + 15;

@interface LoginViewController ()

@end

@implementation LoginViewController {
	MIAButton *backButton;

	UIView *guidView;		// 注册或者登录两个按钮

	UIView *loginView;		// 输入框和登录按钮的页面
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self initUI];
}

-(void)dealloc {
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

#pragma mark - Actions

- (void)backButtonAction:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)signUpButtonAction:(id)sender {
}

- (void)signInButtonAction:(id)sender {
}

@end
