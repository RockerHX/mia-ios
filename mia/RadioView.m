//
//  RadioView.m
//  mia
//
//  Created by linyehui on 2015/09/09.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "RadioView.h"

#import "UIImage+ColorToImage.h"
#import "HJWButton.h"
#import "FSAudioStream.h"

@implementation RadioView {
	HJWButton *pingButton;
	HJWButton *loginButton;
	HJWButton *reconnectButton;
	HJWButton *playButton;

	FSAudioStream *audioStream;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self){
		self.userInteractionEnabled = YES;
//		self.backgroundColor = [UIColor redColor];
		[self loadButtons];

		// init audioStream
		audioStream = [[FSAudioStream alloc] init];
		audioStream.strictContentTypeChecking = NO;
		audioStream.defaultContentType = @"audio/mpeg";
	}

	return self;
}

- (void)loadButtons {
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

- (void)onClickPlayButton:(id)sender {
	NSString *defaultMusic = @"http://miadata1.ufile.ucloud.cn/1b6a1eef28716432d6a0c2dd77c77a71.mp3";
	if ([audioStream isPlaying]) {
		[audioStream pause];

		[playButton setTitle:@"Play" forState:UIControlStateNormal];
	} else {
		if ([audioStream url]) {
			[audioStream pause];
		} else {
			[audioStream playFromURL:[NSURL URLWithString:defaultMusic]];
		}

		[playButton setTitle:@"Pause" forState:UIControlStateNormal];
	}
}

@end
