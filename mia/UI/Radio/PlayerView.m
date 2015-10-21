//
//  PlayerView.m
//  mia
//
//  Created by linyehui on 2015/09/09.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "PlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "UIImage+ColorToImage.h"
#import "MIAButton.h"
#import "MIALabel.h"
#import "MusicPlayerMgr.h"
#import "UIImageView+WebCache.h"
#import "KYCircularView.h"
#import "PXInfiniteScrollView.h"
#import "ShareItem.h"

@implementation PlayerView {
	UIImageView 	*_coverImageView;
	KYCircularView 	*_progressView;
	MIAButton 		*_playButton;
	MIALabel 		*_musicNameLabel;
	MIALabel 		*_musicArtistLabel;
	MIALabel 		*_sharerLabel;
	UITextView 		*_noteTextView;
	NSTimer 		*_progressTimer;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self){
		self.userInteractionEnabled = YES;
		//self.backgroundColor = [UIColor yellowColor];
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
	static const CGFloat kCoverWidth = 160;
	static const CGFloat kCoverHeight = 160;
	static const CGFloat kCoverMarginTop = 5;

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

	static const CGFloat kNoteMarginLeft = 5;
	static const CGFloat kNoteMarginTop = kSharerMarginTop - 3;
	static const CGFloat kNoteMarginRight = 50;
	static const CGFloat kNoteHeight = 60;


	CGRect coverFrame = CGRectMake((self.bounds.size.width - kCoverWidth) / 2,
											 kCoverMarginTop,
											 kCoverWidth,
											 kCoverHeight);
	[self initProgressViewWithCoverFrame:coverFrame];

	_coverImageView = [[UIImageView alloc] initWithFrame:coverFrame];
	[_coverImageView sd_setImageWithURL:nil
					  placeholderImage:[UIImage imageNamed:@"default_cover"]];
	[self addSubview:_coverImageView];

	_playButton = [[MIAButton alloc] initWithFrame:CGRectMake(coverFrame.origin.x + coverFrame.size.width - kPlayButtonMarginRight - kPlayButtonWidth,
															 coverFrame.origin.y + coverFrame.size.height - kPlayButtonMarginBottom - kPlayButtonHeight,
															 kPlayButtonWidth,
															 kPlayButtonHeight)
									  titleString:nil
									   titleColor:nil
											 font:nil
										  logoImg:nil
								  backgroundImage:nil];
	[_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
	[_playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_playButton];

	_musicNameLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kMusicNameMarginLeft,
														  kMusicNameMarginTop,
														  self.bounds.size.width / 2 - kMusicNameMarginLeft + kMusicArtistMarginLeft,
														  kMusicNameHeight)
										  text:@""
										  font:UIFontFromSize(9.0f)
									 textColor:[UIColor blackColor]
								 textAlignment:NSTextAlignmentRight
								   numberLines:1];
	[self addSubview:_musicNameLabel];

	_musicArtistLabel = [[MIALabel alloc] initWithFrame:CGRectMake(self.bounds.size.width / 2 + kMusicArtistMarginLeft,
														  kMusicNameMarginTop,
														  self.bounds.size.width / 2 - kMusicArtistMarginLeft,
														  kMusicArtistHeight)
										  text:@""
										  font:UIFontFromSize(8.0f)
										   textColor:[UIColor grayColor]
									   textAlignment:NSTextAlignmentLeft
								   numberLines:1];
	[self addSubview:_musicArtistLabel];

	_sharerLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kSharerMarginLeft,
																  kSharerMarginTop,
																  _coverImageView.frame.origin.x - kSharerMarginLeft,
																  kSharerHeight)
												  text:@""
												  font:UIFontFromSize(9.0f)
											 textColor:[UIColor blueColor]
										 textAlignment:NSTextAlignmentRight
										   numberLines:1];
	//sharerLabel.backgroundColor = [UIColor yellowColor];
	[self addSubview:_sharerLabel];

	_noteTextView = [[UITextView alloc] initWithFrame:CGRectMake(_coverImageView.frame.origin.x + kNoteMarginLeft,
															   kNoteMarginTop,
															   self.bounds.size.width - _coverImageView.frame.origin.x - kNoteMarginRight,
																kNoteHeight)];
	_noteTextView.text = @"";
	//noteTextView.backgroundColor = [UIColor redColor];
	_noteTextView.scrollEnabled = NO;
	_noteTextView.font = UIFontFromSize(9.0f);
	_noteTextView.userInteractionEnabled = NO;
	[self addSubview:_noteTextView];
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

	[self addSubview:_progressView];
}

- (void)setShareItem:(ShareItem *)item {
	if (!item) {
		// TODO 允许为空，要看下运行是否正常
		NSLog(@"debug nil");
	}

	_shareItem = item;

	[_coverImageView sd_setImageWithURL:[NSURL URLWithString:[[item music] purl]]
					  placeholderImage:[UIImage imageNamed:@"default_cover"]];

	[_musicNameLabel setText:[[item music] name]];
	[_musicArtistLabel setText:[[NSString alloc] initWithFormat:@" - %@", [[item music] singerName]]];
	[_sharerLabel setText:[[NSString alloc] initWithFormat:@"%@ :", [item sNick]]];
	[_noteTextView setText:[item sNote]];
}


#pragma mark - Notification

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

	if (_customDelegate) {
		[_customDelegate playerViewPlayCompletion];
	}
}

#pragma mark - Actions

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
	NSString *musicUrl = [[_shareItem music] murl];
	NSString *musicTitle = [[_shareItem music] name];
	NSString *musicArtist = [[_shareItem music] singerName];

	if (!musicUrl || !musicTitle || !musicArtist) {
		NSLog(@"Music is nil, stop play it.");
		return;
	}

	[_playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
	
	[[MusicPlayerMgr standard] playWithModelID:(long)(__bridge void *)self url:musicUrl title:musicTitle artist:musicArtist];
}

- (void)pauseMusic {
	[_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
	[[MusicPlayerMgr standard] pause];
}

- (void)stopMusic {
	[_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
	[[MusicPlayerMgr standard] stop];
}

- (void)updateProgress:(NSTimer *)timer {
	float postion = [[MusicPlayerMgr standard] getPlayPosition];
	[_progressView setProgress:postion];
}

@end
