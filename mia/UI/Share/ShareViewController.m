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
#import "KYCircularView.h"
#import "MBProgressHUD.h"
#import "MBProgressHUDHelp.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Extrude.h"
#import "CommentCollectionViewCell.h"
#import "DetailHeaderView.h"
#import "MiaAPIHelper.h"
#import "WebSocketMgr.h"
#import "MusicPlayerMgr.h"
#import "Masonry.h"
#import "SearchViewController.h"
#import "SearchResultItem.h"
#import "UserSession.h"
#import "LocationMgr.h"
#import "NSString+IsNull.h"
#import "HXAlertBanner.h"

const static CGFloat kShareTopViewHeight		= 280;

@interface ShareViewController () <UITextFieldDelegate, SearchViewControllerDelegate>

@end

@implementation ShareViewController {
	SearchResultItem 		*_dataItem;
	BOOL 					_isPlayingSearchResult;

	MBProgressHUD 			*_progressHUD;
	MIAButton 				*_sendButton;

	UIView 					*_topView;
	UIView 					*_playerView;
	UIView 					*_addMusicView;
	UIView 					*_bottomView;

	UIImageView 			*_coverImageView;
	KYCircularView 			*_progressView;
	MIAButton 				*_playButton;

	MIALabel 				*_musicNameLabel;
	MIALabel 				*_musicArtistLabel;
	MIALabel 				*_sharerLabel;
	UITextField 			*_commentTextField;

	MIALabel 				*_locationLabel;
	NSTimer 				*_progressTimer;
}

- (id)init {
	self = [super init];
	if (self) {
		//添加键盘监听
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationMusicPlayerMgrDidPlay:) name:MusicPlayerMgrNotificationDidPlay object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationMusicPlayerMgrDidPause:) name:MusicPlayerMgrNotificationDidPause object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationMusicPlayerMgrCompletion:) name:MusicPlayerMgrNotificationCompletion object:nil];
	}

	return self;
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

	[[NSNotificationCenter defaultCenter] removeObserver:self name:MusicPlayerMgrNotificationDidPlay object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MusicPlayerMgrNotificationDidPause object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MusicPlayerMgrNotificationCompletion object:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self initUI];
	[self startUpdatingLocation];
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
	if (_isPlayingSearchResult) {
		[self stopMusic];
	}
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
	static NSString *kDetailTitle = @"分享";
	self.title = kDetailTitle;
	self.view.backgroundColor = [UIColor whiteColor];
	[self initBarButton];

	UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
	gesture.numberOfTapsRequired = 1;
	[self.view addGestureRecognizer:gesture];

	[self initTopView];
	[self initBottomView];
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

	_sendButton = [[MIAButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kSendButtonWidth, kSendButtonHeight)
												 titleString:@"发送"
												  titleColor:UIColorFromHex(@"ff300e", 1.0)
														font:UIFontFromSize(15)
													 logoImg:nil
											 backgroundImage:nil];
	[_sendButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:_sendButton];
	rightButton.enabled = NO;
	self.navigationItem.rightBarButtonItem = rightButton;
	[_sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initTopView {
	_topView = [[UIView alloc] initWithFrame:CGRectMake(0,
													   StatusBarHeight + self.navigationController.navigationBar.frame.size.height,
													   self.view.bounds.size.width,
													   kShareTopViewHeight)];
//	topView.backgroundColor = [UIColor orangeColor];
	[self.view addSubview:_topView];

	static const CGFloat kCoverWidth = 163;
	static const CGFloat kCoverHeight = 163;
	static const CGFloat kCoverMarginTop = 35;

	static const CGFloat kMusicNameMarginTop = kCoverMarginTop + kCoverHeight + 20;
	static const CGFloat kMusicNameMarginLeft = 20;
	static const CGFloat kMusicArtistMarginLeft = 10;
	static const CGFloat kMusicNameHeight = 20;
	static const CGFloat kMusicArtistHeight = 20;

	static const CGFloat kSharerMarginLeft = 20;
	static const CGFloat kSharerMarginTop = kMusicNameMarginTop + kMusicNameHeight + 5;
	static const CGFloat kSharerHeight = 20;
	static const CGFloat kSharerLabelWidth = 80;

	static const CGFloat kNoteMarginLeft = 103;
	static const CGFloat kNoteMarginTop = kSharerMarginTop + 1;
	static const CGFloat kNoteWidth = 200;
	static const CGFloat kNoteHeight = 20;

	CGRect coverFrame = CGRectMake((_topView.bounds.size.width - kCoverWidth) / 2,
								   kCoverMarginTop,
								   kCoverWidth,
								   kCoverHeight);
	[self initPlayerViewWithCoverFrame:coverFrame];
	[self initAddMusicViewWithCoverFrame:coverFrame];

	_musicNameLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kMusicNameMarginLeft,
														  kMusicNameMarginTop,
														  _topView.bounds.size.width / 2 - kMusicNameMarginLeft + kMusicArtistMarginLeft,
														  kMusicNameHeight)
										  text:@""
										  font:UIFontFromSize(15.0f)
										   textColor:[UIColor blackColor]
									   textAlignment:NSTextAlignmentRight
								   numberLines:1];
	[_topView addSubview:_musicNameLabel];

	_musicArtistLabel = [[MIALabel alloc] initWithFrame:CGRectMake(_topView.bounds.size.width / 2 + kMusicArtistMarginLeft,
																  kMusicNameMarginTop,
																  _topView.bounds.size.width / 2 - kMusicArtistMarginLeft,
																  kMusicArtistHeight)
												  text:@""
												  font:UIFontFromSize(15.0f)
											 textColor:[UIColor grayColor]
										 textAlignment:NSTextAlignmentLeft
										   numberLines:1];
	[_topView addSubview:_musicArtistLabel];

	_sharerLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kSharerMarginLeft,
															 kSharerMarginTop,
															 kSharerLabelWidth,
															 kSharerHeight)
											  text:[NSString stringWithFormat:@"%@:", [[UserSession standard] nick]]
											 font:UIFontFromSize(15.0f)
										textColor:[UIColor blueColor]
									textAlignment:NSTextAlignmentRight
									  numberLines:1];
	//sharerLabel.backgroundColor = [UIColor yellowColor];
	[_topView addSubview:_sharerLabel];

	_commentTextField = [[UITextField alloc] initWithFrame:CGRectMake(kNoteMarginLeft,
																	 kNoteMarginTop,
																	 kNoteWidth,
																	 kNoteHeight)];
	_commentTextField.borderStyle = UITextBorderStyleNone;
	_commentTextField.backgroundColor = [UIColor clearColor];
	_commentTextField.textColor = UIColorFromHex(@"#a2a2a2", 1.0);
	_commentTextField.placeholder = @"说说此刻的想法";
	[_commentTextField setFont:UIFontFromSize(16)];
	_commentTextField.keyboardType = UIKeyboardTypeDefault;
	_commentTextField.returnKeyType = UIReturnKeySend;
	_commentTextField.delegate = self;
	//commentTextField.backgroundColor = [UIColor yellowColor];
	[_commentTextField setValue:UIColorFromHex(@"#949494", 1.0) forKeyPath:@"_placeholderLabel.textColor"];
	[_commentTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

	[_topView addSubview:_commentTextField];
}

- (void)initProgressViewWithCoverFrame:(CGRect) coverFrame
{
	_progressView = [[KYCircularView alloc] initWithFrame:CGRectInset(coverFrame, -4, -4)];
	_progressView.colors = @[(__bridge id)ColorHex(0x206fff).CGColor, (__bridge id)ColorHex(0x206fff).CGColor];
	_progressView.backgroundColor = UIColorFromHex(@"dfdfdf", 255.0);
	_progressView.lineWidth = 8.0;

	CGFloat pathWidth = _progressView.frame.size.width;
	CGFloat pathHeight = _progressView.frame.size.height;
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:CGPointMake(pathWidth / 2, pathHeight)];
	[path addLineToPoint:CGPointMake(pathWidth, pathHeight)];
	[path addLineToPoint:CGPointMake(pathWidth, 0)];
	[path addLineToPoint:CGPointMake(0, 0)];
	[path addLineToPoint:CGPointMake(0, pathHeight)];
	[path addLineToPoint:CGPointMake(pathWidth / 2, pathHeight)];
	[path closePath];

	_progressView.path = path;

	[_topView addSubview:_progressView];
}

- (void)initPlayerViewWithCoverFrame:(CGRect)coverFrame {
	_playerView = [[UIView alloc] initWithFrame:coverFrame];
	_playerView.backgroundColor = [UIColor brownColor];
	[_topView addSubview:_playerView];

	_progressView = [[KYCircularView alloc] initWithFrame:CGRectInset(_playerView.bounds, -4, -4)];
	_progressView.colors = @[(__bridge id)ColorHex(0x206fff).CGColor, (__bridge id)ColorHex(0x206fff).CGColor];
	_progressView.backgroundColor = UIColorFromHex(@"dfdfdf", 255.0);
	_progressView.lineWidth = 8.0;

	CGFloat pathWidth = _progressView.frame.size.width;
	CGFloat pathHeight = _progressView.frame.size.height;
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:CGPointMake(pathWidth / 2, pathHeight)];
	[path addLineToPoint:CGPointMake(pathWidth, pathHeight)];
	[path addLineToPoint:CGPointMake(pathWidth, 0)];
	[path addLineToPoint:CGPointMake(0, 0)];
	[path addLineToPoint:CGPointMake(0, pathHeight)];
	[path addLineToPoint:CGPointMake(pathWidth / 2, pathHeight)];
	[path closePath];

	_progressView.path = path;

	[_playerView addSubview:_progressView];

	static const CGFloat kPlayButtonWidth			= 35;
	static const CGFloat kPlayButtonHeight			= 35;
	static const CGFloat kPlayButtonMarginBottom	= 12;
	static const CGFloat kPlayButtonMarginRight		= 12;

	_coverImageView = [[UIImageView alloc] initWithFrame:_playerView.bounds];
	[_coverImageView sd_setImageWithURL:nil
					  placeholderImage:[UIImage imageNamed:@"default_cover"]];
	[_playerView addSubview:_coverImageView];

	_playButton = [[MIAButton alloc] initWithFrame:CGRectMake(_playerView.bounds.origin.x + _playerView.bounds.size.width - kPlayButtonMarginRight - kPlayButtonWidth,
															 _playerView.bounds.origin.y + _playerView.bounds.size.height - kPlayButtonMarginBottom - kPlayButtonHeight,
															 kPlayButtonWidth,
															 kPlayButtonHeight)
									  titleString:nil
									   titleColor:nil
											 font:nil
										  logoImg:nil
								  backgroundImage:nil];
	[_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
	[_playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[_playerView addSubview:_playButton];

	_playerView.hidden = YES;
}

- (void)initAddMusicViewWithCoverFrame:(CGRect)coverFrame {
	_addMusicView = [[UIView alloc] initWithFrame:coverFrame];
	//addMusicView.backgroundColor = [UIColor greenColor];
	[_topView addSubview:_addMusicView];

	UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedAddMusic)];
	gesture.numberOfTapsRequired = 1;
	[_addMusicView addGestureRecognizer:gesture];

	UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:_addMusicView.bounds];
	[bgImageView setImage:[UIImage imageNamed:@"add_music_bg"]];
	[_addMusicView addSubview:bgImageView];

	UIImage *logoImage = [UIImage imageNamed:@"add_music_logo"];
	UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake((_addMusicView.bounds.size.width - logoImage.size.width) / 2,
																			   _addMusicView.bounds.size.height / 2 - logoImage.size.height,
																			   logoImage.size.width,
																			   logoImage.size.height)];
	[logoImageView setImage:logoImage];
	[_addMusicView addSubview:logoImageView];

	const static CGFloat kAddMusicLabelHeight = 25;
	MIALabel *addMusicLabel = [[MIALabel alloc] initWithFrame:CGRectMake(0,
															   _addMusicView.bounds.size.height / 2 + 5,
															   _addMusicView.bounds.size.width,
															   kAddMusicLabelHeight)
											   text:@"添加音乐"
											   font:UIFontFromSize(15.0f)
									   textColor:[UIColor grayColor]
								   textAlignment:NSTextAlignmentCenter
									 numberLines:1];
	[_addMusicView addSubview:addMusicLabel];
}

- (void)initBottomView {
	_bottomView = [UIView new];
	[self.view addSubview:_bottomView];
	_bottomView.hidden = YES;
	//bottomView.backgroundColor = [UIColor redColor];

	UIImageView *locationImageView = [[UIImageView alloc] init];
	[locationImageView setImage:[UIImage imageNamed:@"location"]];
	//locationImageView.backgroundColor = [UIColor greenColor];
	[_bottomView addSubview:locationImageView];

	_locationLabel = [[MIALabel alloc] initWithFrame:CGRectZero
											   text:@""
											   font:UIFontFromSize(12.0f)
									   textColor:[UIColor grayColor]
								   textAlignment:NSTextAlignmentLeft
									 numberLines:1];
	//locationLabel.backgroundColor = [UIColor yellowColor];
	[_bottomView addSubview:_locationLabel];

	MIAButton *closeButton = [[MIAButton alloc] initWithFrame:CGRectZero
										 titleString:nil
										  titleColor:nil
												font:nil
											 logoImg:nil
									 backgroundImage:[UIImage imageNamed:@"close"]];
	[closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	//closeButton.backgroundColor = [UIColor greenColor];
	[_bottomView addSubview:closeButton];

	const static CGFloat kShareBottomViewHeight 		= 20;
	const static CGFloat kShareBottomViewMarginBottom	= 5;
	const static CGFloat kBottomButtonWidth				= 15;
	const static CGFloat kBottomButtonHeight			= 15;
	const static CGFloat kCloseButtonWidth				= 10;

	[_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@(kShareBottomViewHeight));
		make.centerX.equalTo(self.view.mas_centerX);
		make.bottom.equalTo(self.view.mas_bottom).offset(-kShareBottomViewMarginBottom);
	}];

	[locationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.size.mas_equalTo(CGSizeMake(kBottomButtonWidth, kBottomButtonHeight));
		make.left.equalTo(_bottomView.mas_left);
		make.centerY.equalTo(_bottomView.mas_centerY);
	}];
	[_locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(locationImageView.mas_right).offset(5);
		make.right.equalTo(_bottomView.mas_right).offset(-kBottomButtonWidth);
		make.centerY.equalTo(_bottomView.mas_centerY);
		make.height.equalTo(_bottomView.mas_height);
	}];
	[closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.size.mas_equalTo(CGSizeMake(kCloseButtonWidth, kCloseButtonWidth));
		//make.left.equalTo(locationLabel.mas_right);
		make.right.equalTo(_bottomView.mas_right);
		make.centerY.equalTo(_bottomView.mas_centerY);
	}];

}

- (void)startUpdatingLocation {
	[[LocationMgr standard] startUpdatingLocationWithOnceBlock:^(CLLocationCoordinate2D coordinate, NSString *address) {
		if (![NSString isNull:address]) {
			_locationLabel.text = address;
			_bottomView.hidden = NO;
		}
	}];
}

- (void)checkSubmitButtonStatus {
	if ([_playerView isHidden]) {
		[self.navigationItem.rightBarButtonItem setEnabled:NO];
	} else {
		[self.navigationItem.rightBarButtonItem setEnabled:YES];
	}
}

#pragma mark - delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == _commentTextField) {
		[textField resignFirstResponder];
	}

	return true;
}

- (void)textFieldDidChange:(id) sender {
	[self checkSubmitButtonStatus];
}

- (void)searchViewControllerDidSelectedItem:(SearchResultItem *)item {
	_dataItem = item;

	[_addMusicView setHidden:YES];
	[_playerView setHidden:NO];

	[_coverImageView sd_setImageWithURL:[NSURL URLWithString:item.albumPic]
					  placeholderImage:[UIImage imageNamed:@"default_cover"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
						  if (image) {
							  UIImage *newImage = [UIImage imageWithCutImageToSquare:image];
							  //NSLog(@"%f,%f --> %f, %F", image.size.width, image.size.height, newImage.size.width, newImage.size.height);

							  [_coverImageView setImage:newImage];
						  }

					  }];

	[_musicNameLabel setText:item.title];
	[_musicArtistLabel setText:item.artist];

	[MiaAPIHelper getMusicById:item.songID
				 completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
					 NSLog(@"GetMusicById %d", success);
				 } timeoutBlock:^(MiaRequestItem *requestItem) {
					 NSLog(@"GetMusicById timeout");

				 }];
	[_commentTextField becomeFirstResponder];
	[self checkSubmitButtonStatus];
}

- (void)searchViewControllerClickedPlayButtonAtItem:(SearchResultItem *)item {
	if (_dataItem && [item.songUrl isEqualToString:_dataItem.songUrl]) {
		[self pauseMusic];
	} else {
		_dataItem = item;
		[self playMusic];
	}
}

#pragma mark - Notification

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

- (void)notificationMusicPlayerMgrDidPlay:(NSNotification *)notification {
	long modelID = [[notification userInfo][MusicPlayerMgrNotificationKey_ModelID] longValue];
	if (modelID != (long)(__bridge void *)self) {
		NSLog(@"skip other model's notification: notificationMusicPlayerMgrDidPlay");
		return;
	}

	[_playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
	_progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
}

- (void)notificationMusicPlayerMgrDidPause:(NSNotification *)notification {
	long modelID = [[notification userInfo][MusicPlayerMgrNotificationKey_ModelID] longValue];
	if (modelID != (long)(__bridge void *)self) {
		NSLog(@"skip other model's notification: notificationMusicPlayerMgrDidPause");
		return;
	}

	[_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
	[_progressTimer invalidate];
}

- (void)notificationMusicPlayerMgrCompletion:(NSNotification *)notification {
	long modelID = [[notification userInfo][MusicPlayerMgrNotificationKey_ModelID] longValue];
	if (modelID != (long)(__bridge void *)self) {
		NSLog(@"skip other model's notification: notificationMusicPlayerMgrCompletion");
		return;
	}

	[_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
	[_progressTimer invalidate];
}

#pragma mark - keyboard

- (void)moveUpViewForKeyboard:(CGSize)keyboardSize {
	NSTimeInterval animationDuration = 0.30f;
	[UIView beginAnimations:@"ResizeForKeyboard" context:nil];
	[UIView setAnimationDuration:animationDuration];

	CGFloat offset = keyboardSize.height - (self.view.bounds.size.height - _topView.frame.origin.y - _topView.frame.size.height);
	if (offset > 0) {
		CGRect rect = CGRectMake(0,
						  StatusBarHeight + self.navigationController.navigationBar.frame.size.height - offset,
						  self.view.bounds.size.width,
						  kShareTopViewHeight);
		_topView.frame = rect;
	}

	[UIView commitAnimations];
}

- (void)resumeView {
	NSTimeInterval animationDuration = 0.30f;
	[UIView beginAnimations:@"ResizeForKeyboard" context:nil];
	[UIView setAnimationDuration:animationDuration];
	CGRect rect = CGRectMake(0,
							 StatusBarHeight + self.navigationController.navigationBar.frame.size.height,
							 self.view.bounds.size.width,
							 kShareTopViewHeight);
	_topView.frame = rect;
	[UIView commitAnimations];
}

- (void)hidenKeyboard {
	[_commentTextField resignFirstResponder];
	[self checkSubmitButtonStatus];
}

- (void)touchedAddMusic {
	SearchViewController *vc = [[SearchViewController alloc] init];
	vc.searchViewControllerDelegate = self;
	[self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - button Actions

- (void)backButtonAction:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)sendButtonAction:(id)sender {
	NSLog(@"send button clicked.");
	NSString *comment = _commentTextField.text;
	if ([comment length] <= 0) {
		comment = @"我要推荐这首歌曲";
	}

	MBProgressHUD *aMBProgressHUD = [MBProgressHUDHelp showLoadingWithText:@"正在提交分享"];
	[MiaAPIHelper postShareWithLatitude:[[LocationMgr standard] currentCoordinate].latitude
							  longitude:[[LocationMgr standard] currentCoordinate].longitude
								address:[[LocationMgr standard] currentAddress]
								 songID:_dataItem.songID
								   note:comment
						  completeBlock:
	 ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
		 if (success) {
			 [HXAlertBanner showWithMessage:@"分享成功" tap:nil];
			 [self.navigationController popViewControllerAnimated:YES];
		 } else {
			 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
			 [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"分享失败:%@", error] tap:nil];
		 }
		 [aMBProgressHUD removeFromSuperview];
	 } timeoutBlock:^(MiaRequestItem *requestItem) {
		 [aMBProgressHUD removeFromSuperview];
		 [HXAlertBanner showWithMessage:@"分享失败，网络请求超时" tap:nil];
	 }];
}

- (void)closeButtonAction:(id)sender {
	_bottomView.hidden = YES;
}

- (void)playButtonAction:(id)sender {
	NSLog(@"playButtonAction");
	if ([[MusicPlayerMgr standard] isPlaying]) {
		[self pauseMusic];
	} else {
		[self playMusic];
	}
}

#pragma mark - audio operations

- (void)playMusic {
	NSString *url = [_dataItem songUrl];
	NSString *title = [_dataItem title];
	NSString *artist = [_dataItem artist];

	if (!url || !title || !artist) {
		NSLog(@"Music is nil, stop play it.");
		return;
	}

	_isPlayingSearchResult = YES;
	[[MusicPlayerMgr standard] playWithModelID:(long)(__bridge void *)self url:url title:title artist:artist];
	[_playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
}

- (void)pauseMusic {
	[[MusicPlayerMgr standard] pause];
	[_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
}

- (void)stopMusic {
	[[MusicPlayerMgr standard] stop];
	[_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
}

- (void)updateProgress:(NSTimer *)timer {
	float postion = [[MusicPlayerMgr standard] getPlayPosition];
	[_progressView setProgress:postion];
}

@end
