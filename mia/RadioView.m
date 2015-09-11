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

		// 设置后台播放模式
		AVAudioSession *audioSession=[AVAudioSession sharedInstance];
		[audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
		[audioSession setActive:YES error:nil];

		// 添加通知，拔出耳机后暂停播放
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
	}

	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
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

#pragma mark - Notification

/**
 *  一旦输出改变则执行此方法
 *
 *  @param notification 输出改变通知对象
 */
- (void)routeChange:(NSNotification *)notification{
	NSDictionary *dic=notification.userInfo;
	int changeReason= [dic[AVAudioSessionRouteChangeReasonKey] intValue];
	//等于AVAudioSessionRouteChangeReasonOldDeviceUnavailable表示旧输出不可用
	if (changeReason==AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
		AVAudioSessionRouteDescription *routeDescription=dic[AVAudioSessionRouteChangePreviousRouteKey];
		AVAudioSessionPortDescription *portDescription= [routeDescription.outputs firstObject];
		//原设备为耳机则暂停
		if ([portDescription.portType isEqualToString:@"Headphones"]) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self pauseMusic];
			});
		}
	}
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
	if ([audioStream isPlaying]) {
		[self pauseMusic];
	} else {
		[self playMusic];
	}
}

#pragma mark - audio options

- (void)playMusic {
	static NSString *defaultMusic = @"http://miadata1.ufile.ucloud.cn/1b6a1eef28716432d6a0c2dd77c77a71.mp3";

	if ([audioStream url]) {
		[audioStream pause];
	} else {
		[audioStream playFromURL:[NSURL URLWithString:defaultMusic]];
	}

	[self setMediaInfo:nil andTitle:@"春江花月夜" andArtist:@"李健"];
	[playButton setTitle:@"Pause" forState:UIControlStateNormal];

}

- (void)pauseMusic {
	[audioStream pause];

	[playButton setTitle:@"Play" forState:UIControlStateNormal];
}

- (void) setMediaInfo : (UIImage *) img andTitle : (NSString *) title andArtist : (NSString *) artist
{
	NSLog(@"begen set album art, to MPNowPlayingInfoCenter.");
	if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
		NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];


		[dict setObject:title forKey:MPMediaItemPropertyAlbumTitle];
		[dict setObject:artist forKey:MPMediaItemPropertyArtist];

		float totalSeconds = [audioStream duration].minute * 60.0 + [audioStream duration].second;
		[dict setObject:[NSNumber numberWithFloat:totalSeconds] forKey:MPMediaItemPropertyPlaybackDuration];
		[dict setObject:[NSNumber numberWithFloat:[audioStream currentTimePlayed].playbackTimeInSeconds] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];

//		MPMediaItemArtwork * mArt = [[MPMediaItemArtwork alloc] initWithImage:img];
//		[dict setObject:mArt forKey:MPMediaItemPropertyArtwork];
		[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nil;
		[[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
	}
}

@end
