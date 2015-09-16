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

static const CGFloat kCoverWidth = 160;
static const CGFloat kCoverHeight = 160;
static const CGFloat kCoverMarginTop = 90;

static const CGFloat kPlayButtonWidth			= 30;
static const CGFloat kPlayButtonHeight			= 30;
static const CGFloat kPlayButtonMarginBottom	= 5;
static const CGFloat kPlayButtonMarginRight		= 5;

static const CGFloat kMusicNameMarginTop = kCoverMarginTop + kCoverHeight + 20;
static const CGFloat kMusicNameMarginLeft = 20;
static const CGFloat kMusicArtistMarginLeft = 10;
static const CGFloat kMusicNameHeight = 20;
static const CGFloat kMusicArtistHeight = 20;

static const CGFloat kSharerMarginLeft = 20;
static const CGFloat kSharerMarginTop = kMusicNameMarginTop + kMusicNameHeight + 20;
static const CGFloat kSharerHeight = 20;

static const CGFloat kFavoriteMarginBottom = 80;
static const CGFloat kFavoriteWidth = 25;
static const CGFloat kFavoriteHeight = 25;

static const CGFloat kNoteMarginLeft = 5;
static const CGFloat kNoteMarginTop = kSharerMarginTop - 3;
static const CGFloat kNoteMarginRight = 50;
static const CGFloat kNoteHeight = 60;

@implementation RadioView {
	HJWButton *pingButton;
	HJWButton *loginButton;
	HJWButton *reconnectButton;
	HJWLabel *logLabel;

	ShareItem *currentShareItem;

	UIImageView *coverImageView;
	HJWButton *playButton;

	HJWLabel *musicNameLabel;
	HJWLabel *musicArtistLabel;
	HJWLabel *sharerLabel;
	UITextView *noteTextView;

	HJWButton *favoriteButton;
	HJWLabel *commentLabel;
	HJWLabel *viewsLabel;
	HJWLabel *locationLabel;
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
	CGRect coverFrame = CGRectMake((self.bounds.size.width - kCoverWidth) / 2,
											 kCoverMarginTop,
											 kCoverWidth,
											 kCoverHeight);
	coverImageView = [[UIImageView alloc] initWithFrame:coverFrame];
	[coverImageView sd_setImageWithURL:nil
					  placeholderImage:[UIImage imageNamed:@"default_cover.jpg"]];
	[self addSubview:coverImageView];

	playButton = [[HJWButton alloc] initWithFrame:CGRectMake(coverFrame.origin.x + coverFrame.size.width - kPlayButtonMarginRight - kPlayButtonWidth,
															 coverFrame.origin.y + coverFrame.size.height - kPlayButtonMarginBottom - kPlayButtonHeight,
															 kPlayButtonWidth,
															 kPlayButtonHeight)
									  titleString:nil
									   titleColor:nil
											 font:nil
										  logoImg:nil
								  backgroundImage:nil];
	[playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
	[playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:playButton];

	musicNameLabel = [[HJWLabel alloc] initWithFrame:CGRectMake(kMusicNameMarginLeft,
														  kMusicNameMarginTop,
														  self.bounds.size.width / 2 - kMusicNameMarginLeft + kMusicArtistMarginLeft,
														  kMusicNameHeight)
										  text:@""
										  font:UIFontFromSize(9.0f)
									 textColor:[UIColor blackColor]
								 textAlignment:NSTextAlignmentRight
								   numberLines:1];
	[self addSubview:musicNameLabel];

	musicArtistLabel = [[HJWLabel alloc] initWithFrame:CGRectMake(self.bounds.size.width / 2 + kMusicArtistMarginLeft,
														  kMusicNameMarginTop,
														  self.bounds.size.width / 2 - kMusicArtistMarginLeft,
														  kMusicArtistHeight)
										  text:@""
										  font:UIFontFromSize(8.0f)
										   textColor:[UIColor grayColor]
									   textAlignment:NSTextAlignmentLeft
								   numberLines:1];
	[self addSubview:musicArtistLabel];

	sharerLabel = [[HJWLabel alloc] initWithFrame:CGRectMake(kSharerMarginLeft,
																  kSharerMarginTop,
																  coverImageView.frame.origin.x - kSharerMarginLeft,
																  kSharerHeight)
												  text:@""
												  font:UIFontFromSize(9.0f)
											 textColor:[UIColor blueColor]
										 textAlignment:NSTextAlignmentRight
										   numberLines:1];
	//sharerLabel.backgroundColor = [UIColor yellowColor];
	[self addSubview:sharerLabel];

	noteTextView = [[UITextView alloc] initWithFrame:CGRectMake(coverImageView.frame.origin.x + kNoteMarginLeft,
															   kNoteMarginTop,
															   self.bounds.size.width - coverImageView.frame.origin.x - kNoteMarginRight,
																kNoteHeight)];
	noteTextView.text = @"";
	//noteTextView.backgroundColor = [UIColor redColor];
	noteTextView.scrollEnabled = NO;
	noteTextView.font = UIFontFromSize(9.0f);
	noteTextView.userInteractionEnabled = NO;
	[self addSubview:noteTextView];

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

	static const CGFloat kLabelFontSize = 11.0f;
	//用户名
	CGRect logLabelFrame = CGRectMake(10.0f,
									   self.bounds.size.height - 100.0f,
									   self.bounds.size.width - 20,
									   100.0f);
	NSString *nameString = @"Mia Music";
	logLabel = [[HJWLabel alloc] initWithFrame:logLabelFrame
										   text:nameString
										   font:UIFontFromSize(kLabelFontSize)
									  textColor:[UIColor blackColor]
								  textAlignment:NSTextAlignmentCenter
									numberLines:3];
	[self addSubview:logLabel];
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

- (void)setLogText:(NSString *)msg {
	NSDate *now = [NSDate date];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];

	NSString *text = [[NSString alloc]
					  initWithFormat:@"%02ld:%02ld:%02ld %@",
					  (long)[dateComponent hour],
					  [dateComponent minute],
					  [dateComponent second],
					  msg];
	[logLabel setText:text];
}

- (void)setShareItem:(ShareItem *)item {
	if (!item) {
		return;
	}

	currentShareItem = item;

	[coverImageView sd_setImageWithURL:[NSURL URLWithString:[[item music] purl]]
					  placeholderImage:[UIImage imageNamed:@"default_cover.jpg"]];

	[musicNameLabel setText:[[item music] name]];
	[musicArtistLabel setText:[[NSString alloc] initWithFormat:@" - %@", [[item music] singerName]]];
	[sharerLabel setText:[[NSString alloc] initWithFormat:@"%@ :", [item sNick]]];
	[noteTextView setText:[item sNote]];

	[commentLabel setText: 0 == [item cComm] ? @"" : NSStringFromInt([item cComm])];
	[viewsLabel setText: 0 == [item cView] ? @"" : NSStringFromInt([item cView])];
	[locationLabel setText:[item sAddress]];

	[self playMusic];
}

#pragma mark - Notification

- (void)notificationMusicPlayerMgrDidPlay:(NSNotification *)notification {
	[playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
}

- (void)notificationMusicPlayerMgrDidPause:(NSNotification *)notification {
	[playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
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

- (void)playButtonAction:(id)sender {
	NSLog(@"playButtonAction");
	if ([[MusicPlayerMgr standarMusicPlayerMgr] isPlaying]) {
		[self pauseMusic];
	} else {
		[self playMusic];
	}
}

- (void)bottomViewTouchAction:(id)sender {
	NSLog(@"bottomViewTouchAction");
}

#pragma mark - audio operations

- (void)playMusic {
//	static NSString *defaultMusicUrl = @"http://miadata1.ufile.ucloud.cn/1b6a1eef28716432d6a0c2dd77c77a71.mp3";
//	static NSString *defaultMusicTitle = @"贝尔加湖畔";
//	static NSString *defaultMusicArtist = @"李健";

	NSString *musicUrl = [[currentShareItem music] murl];
	NSString *musicTitle = [[currentShareItem music] name];
	NSString *musicArtist = [[currentShareItem music] singerName];

	[[MusicPlayerMgr standarMusicPlayerMgr] playWithUrl:musicUrl andTitle:musicTitle andArtist:musicArtist];
	[playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];

}

- (void)pauseMusic {
	[[MusicPlayerMgr standarMusicPlayerMgr] pause];
	[playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
}

@end
