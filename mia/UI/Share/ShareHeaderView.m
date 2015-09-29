//
//  ShareHeaderView.m
//  mia
//
//  Created by linyehui on 2015/09/09.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "ShareHeaderView.h"
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

@implementation ShareHeaderView {
	UIImageView *coverImageView;
	KYCircularView *progressView;
	MIAButton *playButton;

	MIALabel *musicNameLabel;
	MIALabel *musicArtistLabel;
	MIALabel *sharerLabel;
	UITextView *noteTextView;
	MIALabel *locationLabel;

	NSTimer *progressTimer;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self){
		//self.backgroundColor = [UIColor orangeColor];
		[self initUI];
	}

	return self;
}

- (void)initUI {
	static const CGFloat kCoverWidth = 163;
	static const CGFloat kCoverHeight = 163;
	static const CGFloat kCoverMarginTop = 35;

	static const CGFloat kPlayButtonWidth			= 35;
	static const CGFloat kPlayButtonHeight			= 35;
	static const CGFloat kPlayButtonMarginBottom	= 12;
	static const CGFloat kPlayButtonMarginRight		= 12;

	static const CGFloat kMusicNameMarginTop = kCoverMarginTop + kCoverHeight + 20;
	static const CGFloat kMusicNameMarginLeft = 20;
	static const CGFloat kMusicArtistMarginLeft = 10;
	static const CGFloat kMusicNameHeight = 20;
	static const CGFloat kMusicArtistHeight = 20;

	static const CGFloat kSharerMarginLeft = 20;
	static const CGFloat kSharerMarginTop = kMusicNameMarginTop + kMusicNameHeight + 5;
	static const CGFloat kSharerHeight = 20;

	static const CGFloat kNoteMarginLeft = 5;
	static const CGFloat kNoteMarginTop = kSharerMarginTop - 3;
	static const CGFloat kNoteMarginRight = 50;
	static const CGFloat kNoteHeight = 40;

	static const CGFloat kBottomViewMarginTop = kNoteMarginTop + kNoteHeight + 5;
	static const CGFloat kBottomViewHeight = 35;

	CGRect coverFrame = CGRectMake((self.bounds.size.width - kCoverWidth) / 2,
											 kCoverMarginTop,
											 kCoverWidth,
											 kCoverHeight);
	[self initProgressViewWithCoverFrame:coverFrame];

	coverImageView = [[UIImageView alloc] initWithFrame:coverFrame];
	[coverImageView sd_setImageWithURL:nil
					  placeholderImage:[UIImage imageNamed:@"default_cover"]];
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

	UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0,
																  kBottomViewMarginTop,
																  self.bounds.size.width,
																  kBottomViewHeight)];
	//bottomView.backgroundColor = [UIColor yellowColor];
	[self addSubview:bottomView];
	[self initBottomView:bottomView];
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

- (void)initBottomView:(UIView *)bottomView {
	static const CGFloat kBottomButtonMarginBottom		= 5;
	static const CGFloat kBottomButtonWidth				= 15;
	static const CGFloat kBottomButtonHeight			= 15;
	static const CGFloat kLocationImageMarginRight		= 1;
	static const CGFloat kLocationLabelMarginRight		= 20;
	static const CGFloat kLocationLabelWidth			= 80;

	static const CGFloat kBottomLabelMarginBottom		= 5;
	static const CGFloat kBottomLabelHeight				= 15;


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

- (void)setShareItem:(ShareItem *)item {
	if (!item) {
		// TODO 允许为空，要看下运行是否正常
		NSLog(@"debug nil");
	}

	_shareItem = item;

	[coverImageView sd_setImageWithURL:[NSURL URLWithString:[[item music] purl]]
					  placeholderImage:[UIImage imageNamed:@"default_cover"]];

	[musicNameLabel setText:[[item music] name]];
	[musicArtistLabel setText:[[NSString alloc] initWithFormat:@" - %@", [[item music] singerName]]];
	[sharerLabel setText:[[NSString alloc] initWithFormat:@"%@ :", [item sNick]]];
	[noteTextView setText:[item sNote]];
	[locationLabel setText:[item sAddress]];
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

- (void)favoriteButtonAction:(id)sender {
	NSLog(@"favoriteButtonAction");
}

#pragma mark - audio operations

- (void)playMusic {
//	static NSString *defaultMusicUrl = @"http://miadata1.ufile.ucloud.cn/1b6a1eef28716432d6a0c2dd77c77a71.mp3";
//	static NSString *defaultMusicTitle = @"贝尔加湖畔";
//	static NSString *defaultMusicArtist = @"李健";

	NSString *musicUrl = [[_shareItem music] murl];
	NSString *musicTitle = [[_shareItem music] name];
	NSString *musicArtist = [[_shareItem music] singerName];

	if (!musicUrl || !musicTitle || !musicArtist) {
		NSLog(@"Music is nil, stop play it.");
		return;
	}

	[[MusicPlayerMgr standard] playWithUrl:musicUrl andTitle:musicTitle andArtist:musicArtist];
	[playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];

}

- (void)pauseMusic {
	[[MusicPlayerMgr standard] pause];
	[playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
}

- (void)stopMusic {
	[[MusicPlayerMgr standard] stop];
	[playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
}

- (void)updateProgress:(NSTimer *)timer {
	float postion = [[MusicPlayerMgr standard] getPlayPosition];
	[progressView setProgress:postion];
}

@end
