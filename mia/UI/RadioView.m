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
#import "MIAButton.h"
#import "MIALabel.h"
#import "MusicPlayerMgr.h"
#import "ShareListMgr.h"
#import "MiaAPIHelper.h"
#import "WebSocketMgr.h"
#import "ShareItem.h"
#import "LoopPlayerView.h"

static const CGFloat kPlayerMarginTop			= 90;
static const CGFloat kPlayerHeight				= 300;

static const CGFloat kFavoriteMarginBottom = 80;
static const CGFloat kFavoriteWidth = 25;
static const CGFloat kFavoriteHeight = 25;

@interface RadioView () <LoopPlayerViewDelegate>

@end

@implementation RadioView {
	ShareListMgr *shareListMgr;
	BOOL isLoading;
	
	MIAButton *pingButton;
	MIAButton *loginButton;
	MIAButton *reconnectButton;

	ShareItem *currentShareItem;

	LoopPlayerView *loopPlayerView;

	MIAButton *favoriteButton;
	MIALabel *commentLabel;
	MIALabel *viewsLabel;
	MIALabel *locationLabel;

	NSTimer *progressTimer;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self){
		self.userInteractionEnabled = YES;
//		self.backgroundColor = [UIColor redColor];
		[self initUI];

		[self initPlayerData];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidReceiveMessage:) name:WebSocketMgrNotificationDidReceiveMessage object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationMusicPlayerMgrDidPlay:) name:MusicPlayerMgrNotificationDidPlay object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationMusicPlayerMgrDidPause:) name:MusicPlayerMgrNotificationDidPause object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationMusicPlayerMgrCompletion:) name:MusicPlayerMgrNotificationCompletion object:nil];
	}

	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidReceiveMessage object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MusicPlayerMgrNotificationDidPlay object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MusicPlayerMgrNotificationDidPause object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MusicPlayerMgrNotificationCompletion object:nil];
}

- (void)initUI {
	loopPlayerView = [[LoopPlayerView alloc] initWithFrame:CGRectMake(0, kPlayerMarginTop, self.frame.size.width, kPlayerHeight)];
	loopPlayerView.loopPlayerViewDelegate = self;
	[self addSubview:loopPlayerView];

	favoriteButton = [[MIAButton alloc] initWithFrame:CGRectMake(self.bounds.size.width / 2 - kFavoriteWidth / 2,
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

	pingButton = [[MIAButton alloc] initWithFrame:pingButtonFrame
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

	loginButton = [[MIAButton alloc] initWithFrame:loginButtonFrame
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

	reconnectButton = [[MIAButton alloc] initWithFrame:reconnectButtonFrame
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

	commentLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kCommentImageMarginLeft + kBottomButtonWidth + kCommentLabelMarginLeft,
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

	viewsLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kViewsImageMarginLeft + kBottomButtonWidth + kViewsLabelMarginLeft,
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

	locationLabel = [[MIALabel alloc] initWithFrame:CGRectMake(bottomView.bounds.size.width - kLocationLabelMarginRight - kLocationLabelWidth,
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

- (void)initPlayerData {
	shareListMgr = [ShareListMgr initFromArchive];
	isLoading = YES;
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

-(void)notificationWebSocketDidReceiveMessage:(NSNotification *)notification {
	NSString *command = [notification userInfo][MiaAPIKey_ServerCommand];
	NSLog(@"%@", command);

	if ([command isEqualToString:MiaAPICommand_Music_GetNearby]) {
		[self handleNearbyFeeds:[notification userInfo]];
	}
}

- (void)notificationMusicPlayerMgrDidPlay:(NSNotification *)notification {
	[loopPlayerView notifyMusicPlayerMgrDidPlay];
}

- (void)notificationMusicPlayerMgrDidPause:(NSNotification *)notification {
	[loopPlayerView notifyMusicPlayerMgrDidPause];
}

- (void)notificationMusicPlayerMgrCompletion:(NSNotification *)notification {
	[self notifySwipeLeft];
}

#pragma mark - received message from websocket

- (void)handleNearbyFeeds:(NSDictionary *) userInfo {
	NSArray *shareList = userInfo[@"v"][@"data"];
	if (!shareList)
		return;

	[shareListMgr addSharesWithArray:shareList];

	if (isLoading) {
		[self showNextShare];
		isLoading = NO;
	}

	[shareListMgr saveChanges];
}

- (ShareItem *)showNextShare {
	ShareItem *currentItem = [shareListMgr popShareItem];
	if ([shareListMgr getOnlineCount] == 0) {
		// TODO linyehui
		[MiaAPIHelper getNearbyWithLatitude:-22 longitude:33 start:1 item:1];
	}

	[self setShareItem:currentItem];

	return currentItem;
}

- (void)spreadFeed {
	NSLog(@"#swipe# up spred");
}

- (void)skipFeed {
	NSLog(@"#swipe# down");
}

#pragma mark - LoopPlayerViewDelegate

- (void)notifySwipeLeft {
	NSLog(@"#swipe# left");

	[self showNextShare];
}

- (void)notifySwipeRight {
	NSLog(@"#swipe# right");
}

#pragma mark - Actions

- (void)favoriteButtonAction:(id)sender {
	NSLog(@"favoriteButtonAction");
}

- (void)bottomViewTouchAction:(id)sender {
	NSLog(@"bottomViewTouchAction");
}

@end
