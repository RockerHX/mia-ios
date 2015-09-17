//
//  RadioView.m
//  mia
//
//  Created by linyehui on 2015/09/09.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "RadioView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "UIImage+ColorToImage.h"
#import "HJWButton.h"
#import "HJWLabel.h"
#import "MusicPlayerMgr.h"
#import "UIImageView+WebCache.h"
#import "KYCircularView.h"
#import "PXInfiniteScrollView.h"
#import "LoopPlayerView.h"

static const CGFloat kPlayerMarginTop			= 90;
static const CGFloat kPlayerHeight				= 300;

static const CGFloat kFavoriteMarginBottom = 80;
static const CGFloat kFavoriteWidth = 25;
static const CGFloat kFavoriteHeight = 25;


@implementation RadioView {
	HJWButton *pingButton;
	HJWButton *loginButton;
	HJWButton *reconnectButton;

	ShareItem *currentShareItem;

	LoopPlayerView *loopPlayerView;
	PXInfiniteScrollView *playerScrollView;

	HJWButton *favoriteButton;
	HJWLabel *commentLabel;
	HJWLabel *viewsLabel;
	HJWLabel *locationLabel;

	NSTimer *progressTimer;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self){
		self.userInteractionEnabled = YES;
//		self.backgroundColor = [UIColor redColor];
		[self initUI];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationMusicPlayerMgrDidPlay:) name:MusicPlayerMgrNotificationDidPlay object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationMusicPlayerMgrDidPause:) name:MusicPlayerMgrNotificationDidPause object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationMusicPlayerMgrCompletion:) name:MusicPlayerMgrNotificationCompletion object:nil];
	}

	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MusicPlayerMgrNotificationDidPlay object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MusicPlayerMgrNotificationDidPause object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MusicPlayerMgrNotificationCompletion object:nil];
}

- (void)initUI {
	loopPlayerView = [[LoopPlayerView alloc] initWithFrame:CGRectMake(0, kPlayerMarginTop, self.frame.size.width, kPlayerHeight)];
	[self addSubview:loopPlayerView];

	[self initPlayerUI];

	favoriteButton = [[HJWButton alloc] initWithFrame:CGRectMake(self.bounds.size.width / 2 - kFavoriteWidth / 2,
																 self.bounds.size.height - kFavoriteMarginBottom - kFavoriteHeight,
																 kFavoriteWidth,
																 kFavoriteHeight)
										  titleString:nil
										   titleColor:nil
												 font:nil
											  logoImg:nil
									  backgroundImage:nil];
	[favoriteButton setImage:[UIImage imageNamed:@"favorite_normal"] forState:UIControlStateNormal];
	[favoriteButton addTarget:self action:@selector(favoriteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:favoriteButton];

	[self initBottomView];
/*
	CGRect pingButtonFrame = CGRectMake(60,
										50.0f,
										200,
										50);

	pingButton = [[HJWButton alloc] initWithFrame:pingButtonFrame
									  titleString:@"Ping" titleColor:[UIColor whiteColor]
											 font:UIFontFromSize(15)
										  logoImg:nil
								  backgroundImage:[UIImage createImageWithColor:DADU_DEFAULT_COLOR]];

	pingButton.layer.masksToBounds = YES;
	pingButton.layer.cornerRadius = 5.0f;
	[pingButton addTarget:self action:@selector(onClickPingButton:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:pingButton];

	CGRect loginButtonFrame = CGRectMake(60,
										130.0f,
										200,
										50);

	loginButton = [[HJWButton alloc] initWithFrame:loginButtonFrame
									  titleString:@"Login" titleColor:[UIColor whiteColor]
											 font:UIFontFromSize(15)
										  logoImg:nil
								  backgroundImage:[UIImage createImageWithColor:DADU_DEFAULT_COLOR]];

	loginButton.layer.masksToBounds = YES;
	loginButton.layer.cornerRadius = 5.0f;
	[loginButton addTarget:self action:@selector(onClickLoginButton:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:loginButton];
	
	CGRect reconnectButtonFrame = CGRectMake(60,
										 210.0f,
										 200,
										 50);

	reconnectButton = [[HJWButton alloc] initWithFrame:reconnectButtonFrame
									   titleString:@"Reconnect" titleColor:[UIColor whiteColor]
											  font:UIFontFromSize(15)
										   logoImg:nil
								   backgroundImage:[UIImage createImageWithColor:DADU_DEFAULT_COLOR]];

	reconnectButton.layer.masksToBounds = YES;
	reconnectButton.layer.cornerRadius = 5.0f;
	[reconnectButton addTarget:self action:@selector(onClickReconnectButton:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:reconnectButton];

*/
}

- (void)initPlayerUI {
	playerScrollView = [[PXInfiniteScrollView alloc] initWithFrame:CGRectMake(0, kPlayerMarginTop, self.frame.size.width, 300)];
	playerScrollView.backgroundColor = [UIColor redColor];
	[playerScrollView setTranslatesAutoresizingMaskIntoConstraints:FALSE];
	[playerScrollView setScrollDirection:PXInfiniteScrollViewDirectionHorizontal];
	//[self addSubview:playerScrollView];

	UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
	view1.backgroundColor = [UIColor grayColor];
	UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
	view2.backgroundColor = [UIColor yellowColor];
	UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
	view3.backgroundColor = [UIColor greenColor];
	NSArray *viewArray = [[NSArray alloc] initWithObjects:view1, view2, view3, nil];
	[playerScrollView setPages:viewArray];
}

- (void)initBottomView {
	static const CGFloat kBottomViewHeight				= 35;
	static const CGFloat kBottomButtonMarginBottom		= 20;
	static const CGFloat kBottomButtonWidth				= 15;
	static const CGFloat kBottomButtonHeight			= 15;
	static const CGFloat kCommentImageMarginLeft		= 20;
	static const CGFloat kViewsImageMarginLeft			= 60;
	static const CGFloat kLocationImageMarginRight		= 1;
	static const CGFloat kLocationLabelMarginRight		= 20;
	static const CGFloat kLocationLabelWidth			= 80;

	static const CGFloat kCommentLabelMarginLeft		= 2;
	static const CGFloat kBottomLabelMarginBottom		= 20;
	static const CGFloat kBottomLabelHeight				= 15;
	static const CGFloat kCommentLabelWidth				= 20;

	static const CGFloat kViewsLabelMarginLeft			= 2;
	static const CGFloat kViewsLabelWidth				= 20;

	UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - kBottomViewHeight, self.bounds.size.width, kBottomViewHeight)];
	//bottomView.backgroundColor = [UIColor redColor];
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bottomViewTouchAction:)];
	[bottomView addGestureRecognizer:tap];
	[self addSubview:bottomView];

	UIImageView *commentsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kCommentImageMarginLeft,
																				   bottomView.bounds.size.height - kBottomButtonMarginBottom - kBottomButtonHeight,
																				   kBottomButtonWidth,
																				   kBottomButtonHeight)];
	[commentsImageView setImage:[UIImage imageNamed:@"comments"]];
	[bottomView addSubview:commentsImageView];

	commentLabel = [[HJWLabel alloc] initWithFrame:CGRectMake(kCommentImageMarginLeft + kBottomButtonWidth + kCommentLabelMarginLeft,
															  bottomView.bounds.size.height - kBottomLabelMarginBottom - kBottomLabelHeight,
															  kCommentLabelWidth,
															  kBottomLabelHeight)
											  text:@""
											  font:UIFontFromSize(8.0f)
										 textColor:[UIColor grayColor]
									 textAlignment:NSTextAlignmentLeft
									   numberLines:1];
	//commentLabel.backgroundColor = [UIColor redColor];
	[bottomView addSubview:commentLabel];

	UIImageView *viewsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kViewsImageMarginLeft,
																				bottomView.bounds.size.height - kBottomButtonMarginBottom - kBottomButtonHeight,
																				kBottomButtonWidth,
																				kBottomButtonHeight)];
	[viewsImageView setImage:[UIImage imageNamed:@"views"]];
	[bottomView addSubview:viewsImageView];

	viewsLabel = [[HJWLabel alloc] initWithFrame:CGRectMake(kViewsImageMarginLeft + kBottomButtonWidth + kViewsLabelMarginLeft,
															bottomView.bounds.size.height - kBottomLabelMarginBottom - kBottomLabelHeight,
															kViewsLabelWidth,
															kBottomLabelHeight)
											text:@""
											font:UIFontFromSize(8.0f)
									   textColor:[UIColor grayColor]
								   textAlignment:NSTextAlignmentLeft
									 numberLines:1];
	//viewsLabel.backgroundColor = [UIColor redColor];
	[bottomView addSubview:viewsLabel];

	UIImageView *locationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(bottomView.bounds.size.width - kLocationLabelMarginRight - kLocationLabelWidth - kLocationImageMarginRight - kBottomButtonWidth,
																				   bottomView.bounds.size.height - kBottomButtonMarginBottom - kBottomButtonHeight,
																				   kBottomButtonWidth,
																				   kBottomButtonHeight)];
	[locationImageView setImage:[UIImage imageNamed:@"location"]];
	[bottomView addSubview:locationImageView];

	locationLabel = [[HJWLabel alloc] initWithFrame:CGRectMake(bottomView.bounds.size.width - kLocationLabelMarginRight - kLocationLabelWidth,
															   bottomView.bounds.size.height - kBottomLabelMarginBottom - kBottomLabelHeight,
															   kLocationLabelWidth,
															   kBottomLabelHeight)
											   text:@""
											   font:UIFontFromSize(8.0f)
									   textColor:[UIColor grayColor]
								   textAlignment:NSTextAlignmentLeft
									 numberLines:1];
	//locationLabel.backgroundColor = [UIColor redColor];
	[bottomView addSubview:locationLabel];
}

- (void)setShareItem:(ShareItem *)item {
	if (!item) {
		return;
	}

	currentShareItem = item;

	[loopPlayerView setShareItem:item];

	[commentLabel setText: 0 == [item cComm] ? @"" : NSStringFromInt([item cComm])];
	[viewsLabel setText: 0 == [item cView] ? @"" : NSStringFromInt([item cView])];
	[locationLabel setText:[item sAddress]];
}

#pragma mark - Notification

- (void)notificationMusicPlayerMgrDidPlay:(NSNotification *)notification {
	[loopPlayerView notifyMusicPlayerMgrDidPlay];
}

- (void)notificationMusicPlayerMgrDidPause:(NSNotification *)notification {
	[loopPlayerView notifyMusicPlayerMgrDidPause];
}

- (void)notificationMusicPlayerMgrCompletion:(NSNotification *)notification {
	NSLog(@"play next song");
	[self.radioViewDelegate notifyPlayCompletion];
}

#pragma mark - Actions

- (void)onClickPingButton:(id)sender {
	NSLog(@"OnClick Ping");
	[self.radioViewDelegate notifyPing];
}

- (void)onClickLoginButton:(id)sender {
	NSLog(@"OnClick Login");
	[self.radioViewDelegate notifyLogin];
}

- (void)onClickReconnectButton:(id)sender {
	NSLog(@"OnClick Reconnect");
	[self.radioViewDelegate notifyReconnect];
}

- (void)favoriteButtonAction:(id)sender {
	NSLog(@"favoriteButtonAction");
}

- (void)bottomViewTouchAction:(id)sender {
	NSLog(@"bottomViewTouchAction");
}

@end
