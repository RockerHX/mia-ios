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

@implementation PlayerView {
	ShareItem *currentShareItem;

	UIImageView *coverImageView;
	KYCircularView *progressView;
	MIAButton *playButton;

	MIALabel *musicNameLabel;
	MIALabel *musicArtistLabel;
	MIALabel *sharerLabel;
	UITextView *noteTextView;

	NSTimer *progressTimer;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self){
		self.userInteractionEnabled = YES;
		//self.backgroundColor = [UIColor yellowColor];
		[self initUI];
	}

	return self;
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

	coverImageView = [[UIImageView alloc] initWithFrame:coverFrame];
	[coverImageView sd_setImageWithURL:nil
					  placeholderImage:[UIImage imageNamed:@"default_cover.jpg"]];
	[self addSubview:coverImageView];

	playButton = [[MIAButton alloc] initWithFrame:CGRectMake(coverFrame.origin.x + coverFrame.size.width - kPlayButtonMarginRight - kPlayButtonWidth,
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

	musicNameLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kMusicNameMarginLeft,
														  kMusicNameMarginTop,
														  self.bounds.size.width / 2 - kMusicNameMarginLeft + kMusicArtistMarginLeft,
														  kMusicNameHeight)
										  text:@""
										  font:UIFontFromSize(9.0f)
									 textColor:[UIColor blackColor]
								 textAlignment:NSTextAlignmentRight
								   numberLines:1];
	[self addSubview:musicNameLabel];

	musicArtistLabel = [[MIALabel alloc] initWithFrame:CGRectMake(self.bounds.size.width / 2 + kMusicArtistMarginLeft,
														  kMusicNameMarginTop,
														  self.bounds.size.width / 2 - kMusicArtistMarginLeft,
														  kMusicArtistHeight)
										  text:@""
										  font:UIFontFromSize(8.0f)
										   textColor:[UIColor grayColor]
									   textAlignment:NSTextAlignmentLeft
								   numberLines:1];
	[self addSubview:musicArtistLabel];

	sharerLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kSharerMarginLeft,
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
}

- (void)initProgressViewWithCoverFrame:(CGRect) coverFrame
{
	progressView = [[KYCircularView alloc] initWithFrame:CGRectInset(coverFrame, -4, -4)];
	progressView.colors = @[(__bridge id)ColorHex(0x206fff).CGColor, (__bridge id)ColorHex(0x206fff).CGColor];
	progressView.backgroundColor = UIColorFromHex(@"dfdfdf", 255.0);
	progressView.lineWidth = 8.0;

	CGFloat pathWidth = progressView.frame.size.width;
	CGFloat pathHeight = progressView.frame.size.height;
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:CGPointMake(pathWidth / 2, pathHeight)];
	[path addLineToPoint:CGPointMake(pathWidth, pathHeight)];
	[path addLineToPoint:CGPointMake(pathWidth, 0)];
	[path addLineToPoint:CGPointMake(0, 0)];
	[path addLineToPoint:CGPointMake(0, pathHeight)];
	[path addLineToPoint:CGPointMake(pathWidth / 2, pathHeight)];
	[path closePath];

	progressView.path = path;

	[self addSubview:progressView];
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

	[self playMusic];
}

- (void)notifyMusicPlayerMgrDidPlay {
	[playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
	progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
}

- (void)notifyMusicPlayerMgrDidPause {
	[playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
	[progressTimer invalidate];
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
//	static NSString *defaultMusicUrl = @"http://miadata1.ufile.ucloud.cn/1b6a1eef28716432d6a0c2dd77c77a71.mp3";
//	static NSString *defaultMusicTitle = @"贝尔加湖畔";
//	static NSString *defaultMusicArtist = @"李健";

	NSString *musicUrl = [[currentShareItem music] murl];
	NSString *musicTitle = [[currentShareItem music] name];
	NSString *musicArtist = [[currentShareItem music] singerName];

	[[MusicPlayerMgr standard] playWithUrl:musicUrl andTitle:musicTitle andArtist:musicArtist];
	[playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];

}

- (void)pauseMusic {
	[[MusicPlayerMgr standard] pause];
	[playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
}

- (void)updateProgress:(NSTimer *)timer {
	float postion = [[MusicPlayerMgr standard] getPlayPosition];
	[progressView setProgress:postion];
}

@end
