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

@implementation RadioView {
	HJWButton *pingButton;
	HJWButton *loginButton;
	HJWButton *reconnectButton;
	HJWButton *playButton;
	HJWLabel *logLabel;

	UIImageView *coverImageView;
	HJWLabel *musicNameLabel;
	HJWLabel *musicArtistLabel;
	HJWLabel *sharerLabel;
	HJWLabel *noteLabel;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self){
		self.userInteractionEnabled = YES;
//		self.backgroundColor = [UIColor redColor];
		[self initUI];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationMusicPlayerMgrDidPlay:) name:MusicPlayerMgrNotificationDidPlay object:[MusicPlayerMgr standarMusicPlayerMgr]];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationMusicPlayerMgrDidPause:) name:MusicPlayerMgrNotificationDidPause object:[MusicPlayerMgr standarMusicPlayerMgr]];
	}

	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MusicPlayerMgrNotificationDidPlay object:[MusicPlayerMgr standarMusicPlayerMgr]];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MusicPlayerMgrNotificationDidPause object:[MusicPlayerMgr standarMusicPlayerMgr]];
}

- (void)initUI {
	static const CGFloat kCoverWidth = 160;
	static const CGFloat kCoverHeight = 160;
	static const CGFloat kCoverMarginTop = 90;

	static const CGFloat kMusicNameMarginTop = kCoverMarginTop + kCoverHeight + 20;
	static const CGFloat kMusicNameMarginLeft = 20;
	static const CGFloat kMusicArtistMarginLeft = 10;
	static const CGFloat kMusicNameHeight = 20;
	static const CGFloat kMusicArtistHeight = 20;

	static const CGFloat kSharerMarginLeft = 20;
	static const CGFloat kSharerMarginTop = kMusicNameMarginTop + kMusicNameHeight + 20;
	static const CGFloat kSharerHeight = 20;

	static const CGFloat kNoteMarginLeft = 5;
	static const CGFloat kNoteMarginTop = kSharerMarginTop;
	static const CGFloat kNoteMarginRight = 50;
	static const CGFloat kNoteHeight = 20;

	CGRect aboutBackgroundFrame = CGRectMake((self.bounds.size.width - kCoverWidth) / 2,
											 kCoverMarginTop,
											 kCoverWidth,
											 kCoverHeight);
	coverImageView = [[UIImageView alloc] initWithFrame:aboutBackgroundFrame];
	[coverImageView sd_setImageWithURL:nil
					  placeholderImage:[UIImage imageNamed:@"default_cover.jpg"]];
	[self addSubview:coverImageView];

	musicNameLabel = [[HJWLabel alloc] initWithFrame:CGRectMake(kMusicNameMarginLeft,
														  kMusicNameMarginTop,
														  self.bounds.size.width / 2 - kMusicNameMarginLeft + kMusicArtistMarginLeft,
														  kMusicNameHeight)
										  text:@"Castle Walls"
										  font:UIFontFromSize(9.0f)
									 textColor:[UIColor blackColor]
								 textAlignment:NSTextAlignmentRight
								   numberLines:1];
	[self addSubview:musicNameLabel];

	musicArtistLabel = [[HJWLabel alloc] initWithFrame:CGRectMake(self.bounds.size.width / 2 + kMusicArtistMarginLeft,
														  kMusicNameMarginTop,
														  self.bounds.size.width / 2 - kMusicArtistMarginLeft,
														  kMusicArtistHeight)
										  text:@" - Mercy"
										  font:UIFontFromSize(8.0f)
										   textColor:[UIColor grayColor]
									   textAlignment:NSTextAlignmentLeft
								   numberLines:1];
	[self addSubview:musicArtistLabel];

	sharerLabel = [[HJWLabel alloc] initWithFrame:CGRectMake(kSharerMarginLeft,
																  kSharerMarginTop,
																  coverImageView.frame.origin.x - kSharerMarginLeft,
																  kSharerHeight)
												  text:@"Aaronbing:"
												  font:UIFontFromSize(9.0f)
											 textColor:[UIColor blueColor]
										 textAlignment:NSTextAlignmentRight
										   numberLines:1];
	//sharerLabel.backgroundColor = [UIColor yellowColor];
	[self addSubview:sharerLabel];

	noteLabel = [[HJWLabel alloc] initWithFrame:CGRectMake(coverImageView.frame.origin.x + kNoteMarginLeft,
															 kNoteMarginTop,
															 self.bounds.size.width - coverImageView.frame.origin.x - kNoteMarginRight,
															 kNoteHeight)
											 text:@"灵乐盛行时期的巅峰之作，表达痛苦与傍徨。"
											 font:UIFontFromSize(9.0f)
										textColor:[UIColor blackColor]
									textAlignment:NSTextAlignmentLeft
									  numberLines:1];
	//[noteLabel alignTop];
	//noteLabel.backgroundColor = [UIColor redColor];
	[self addSubview:noteLabel];

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

	CGRect playButtonFrame = CGRectMake(60,
											 290.0f,
											 200,
											 50);

	playButton = [[HJWButton alloc] initWithFrame:playButtonFrame
										   titleString:@"Play" titleColor:[UIColor whiteColor]
												  font:UIFontFromSize(15)
											   logoImg:nil
									   backgroundImage:[UIImage createImageWithColor:DADU_DEFAULT_COLOR]];

	playButton.layer.masksToBounds = YES;
	playButton.layer.cornerRadius = 5.0f;
	[playButton addTarget:self action:@selector(onClickPlayButton:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:playButton];

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

#pragma mark - Notification

- (void)notificationMusicPlayerMgrDidPlay:(NSNotification *)notification {
	[playButton setTitle:@"Pause" forState:UIControlStateNormal];
}

- (void)notificationMusicPlayerMgrDidPause:(NSNotification *)notification {
	[playButton setTitle:@"Play" forState:UIControlStateNormal];
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

	// for test
//	static NSString *defaultMusicUrl = @"http://miadata1.ufile.ucloud.cn/e8ace5fe6fdd0b3eea0a0d717d562b98.mp3";
//	static NSString *defaultMusicTitle = @"轻音乐";
//	static NSString *defaultMusicArtist = @"小虫";
//
//	[[MusicPlayerMgr standarMusicPlayerMgr] playWithUrl:defaultMusicUrl andTitle:defaultMusicTitle andArtist:defaultMusicArtist];
//	[playButton setTitle:@"Pause" forState:UIControlStateNormal];
}

- (void)onClickPlayButton:(id)sender {
	if ([[MusicPlayerMgr standarMusicPlayerMgr] isPlaying]) {
		[self pauseMusic];
	} else {
		[self playMusic];
	}
}

#pragma mark - audio operations

- (void)playMusic {
	static NSString *defaultMusicUrl = @"http://miadata1.ufile.ucloud.cn/1b6a1eef28716432d6a0c2dd77c77a71.mp3";
	static NSString *defaultMusicTitle = @"贝尔加湖畔";
	static NSString *defaultMusicArtist = @"李健";

	[[MusicPlayerMgr standarMusicPlayerMgr] playWithUrl:defaultMusicUrl andTitle:defaultMusicTitle andArtist:defaultMusicArtist];
	[playButton setTitle:@"Pause" forState:UIControlStateNormal];

}

- (void)pauseMusic {
	[[MusicPlayerMgr standarMusicPlayerMgr] pause];
	[playButton setTitle:@"Play" forState:UIControlStateNormal];
}

@end
