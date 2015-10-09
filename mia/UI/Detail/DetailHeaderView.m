//
//  DetailHeaderView.m
//  mia
//
//  Created by linyehui on 2015/09/09.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "DetailHeaderView.h"
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
#import "UserSession.h"
#import "MiaAPIHelper.h"
#import "Masonry.h"

const static CGFloat kProgressLineWidth = 8.0;

@implementation DetailHeaderView {
	UIImageView 	*_coverImageView;
	KYCircularView	*_progressView;
	MIAButton 		*_playButton;

	UIView 			*_songView;
	MIALabel 		*_musicNameLabel;
	MIALabel 		*_musicArtistLabel;

	UIView			*_noteView;
	MIALabel 		*_sharerLabel;
	MIALabel 		*_noteLabel;
	MIAButton 		*_favoriteButton;

	UIView 			*_bottomView;
	MIALabel 		*_commentLabel;
	MIALabel 		*_viewsLabel;
	MIALabel 		*_locationLabel;
	NSTimer 		*_progressTimer;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self){
		//self.backgroundColor = [UIColor orangeColor];
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
	[self initCoverView];
	[self initSongView];
	[self initNoteView];
	[self initBottomView];
}

- (void)initCoverView {
	static const CGFloat kCoverWidth 				= 163;
	static const CGFloat kCoverHeight 				= 163;

	[self initProgressViewWithCoverSize:CGSizeMake(kCoverWidth + kProgressLineWidth, kCoverHeight + kProgressLineWidth)];

	_coverImageView = [[UIImageView alloc] init];
	[_coverImageView sd_setImageWithURL:nil
					   placeholderImage:[UIImage imageNamed:@"default_cover"]];
	[self addSubview:_coverImageView];

	_playButton = [[MIAButton alloc] initWithFrame:CGRectZero
									   titleString:nil
										titleColor:nil
											  font:nil
										   logoImg:nil
								   backgroundImage:nil];
	[_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
	[_playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_playButton];

	[_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.mas_centerX);
		make.size.mas_equalTo(CGSizeMake(kCoverWidth, kCoverHeight));
		make.top.equalTo(self.mas_top).with.offset(35);
	}];

	[_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(_coverImageView).with.insets(UIEdgeInsetsMake(-4, -4, -4, -4));
	}];

	[_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.size.mas_equalTo(CGSizeMake(35, 35));
		make.right.equalTo(_coverImageView.mas_right).with.offset(-12);
		make.bottom.equalTo(_coverImageView.mas_bottom).with.offset(-12);
	}];

}

- (void)initSongView {
	_songView = [[UIView alloc] init];
	//songView.backgroundColor = [UIColor greenColor];
	[self addSubview:_songView];

	_musicNameLabel = [[MIALabel alloc] initWithFrame:CGRectZero
												 text:@""
												 font:UIFontFromSize(9.0f)
											textColor:[UIColor blackColor]
										textAlignment:NSTextAlignmentLeft
										  numberLines:1];
	[_songView addSubview:_musicNameLabel];

	_musicArtistLabel = [[MIALabel alloc] initWithFrame:CGRectZero
												   text:@""
												   font:UIFontFromSize(8.0f)
										   textColor:UIColorFromHex(@"a2a2a2", 1.0)
									   textAlignment:NSTextAlignmentLeft
								   numberLines:1];
	[_songView addSubview:_musicArtistLabel];

	_favoriteButton = [[MIAButton alloc] initWithFrame:CGRectZero
										   titleString:nil
											titleColor:nil
												  font:nil
											   logoImg:nil
									   backgroundImage:nil];
	[_favoriteButton setImage:[UIImage imageNamed:@"favorite_normal"] forState:UIControlStateNormal];
	[_favoriteButton addTarget:self action:@selector(favoriteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[_songView addSubview:_favoriteButton];

	[_songView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.mas_centerX);
		make.top.equalTo(_coverImageView.mas_bottom).with.offset(20);
		make.width.lessThanOrEqualTo(self.mas_width);
	}];

	[_musicNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_songView.mas_left);
		make.right.equalTo(_musicArtistLabel.mas_left);
		make.top.equalTo(_songView.mas_top);
		make.bottom.equalTo(_songView.mas_bottom);
	}];
	[_musicArtistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_musicNameLabel.mas_right);
		make.right.equalTo(_favoriteButton.mas_left).with.offset(-15);
		make.top.equalTo(_songView.mas_top);
		make.bottom.equalTo(_songView.mas_bottom);
	}];
	[_favoriteButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_musicArtistLabel.mas_right).with.offset(15);
		make.right.equalTo(_songView.mas_right);
		make.size.mas_equalTo(CGSizeMake(15, 15));
		make.centerY.equalTo(_songView.mas_centerY);
	}];
}

- (void)initNoteView {
	_noteView = [[UIView alloc] init];
	//_noteView.backgroundColor = [UIColor greenColor];
	[self addSubview:_noteView];

	_sharerLabel = [[MIALabel alloc] initWithFrame:CGRectZero
											  text:@""
											  font:UIFontFromSize(9.0f)
										 textColor:[UIColor blueColor]
									 textAlignment:NSTextAlignmentRight
									   numberLines:1];
	//_sharerLabel.backgroundColor = [UIColor yellowColor];
	[_noteView addSubview:_sharerLabel];

	_noteLabel = [[MIALabel alloc] initWithFrame:CGRectZero
											  text:@""
											  font:UIFontFromSize(9.0f)
										 textColor:[UIColor blackColor]
									 textAlignment:NSTextAlignmentLeft
									   numberLines:0];
	//_noteLabel.backgroundColor = [UIColor redColor];
	[_noteView addSubview:_noteLabel];

	[_noteView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(_songView.mas_bottom).with.offset(20);
		make.left.equalTo(self.mas_left).with.offset(30);
		make.right.equalTo(self.mas_right).with.offset(-30);
	}];

	[_sharerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_noteView.mas_left);
		make.top.equalTo(_noteView.mas_top);
		make.width.greaterThanOrEqualTo(@30);
		make.width.lessThanOrEqualTo(@60);
	}];
	[_noteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_sharerLabel.mas_right).with.offset(2);
		make.right.equalTo(_noteView.mas_right);
		make.top.equalTo(_noteView.mas_top);
	}];
}

- (void)initProgressViewWithCoverSize:(CGSize)coverSize {
	// 这个控件需要初始化的时候就给他一个大小，否则画图会有问题
	// linyehui 2015-10-09 16:57
	_progressView = [[KYCircularView alloc] initWithFrame:CGRectMake(0, 0, coverSize.width, coverSize.height)];
	_progressView.colors = @[(__bridge id)ColorHex(0x206fff).CGColor, (__bridge id)ColorHex(0x206fff).CGColor];
	_progressView.backgroundColor = UIColorFromHex(@"dfdfdf", 255.0);
	_progressView.lineWidth = kProgressLineWidth;

	CGFloat pathWidth = coverSize.width;
	CGFloat pathHeight = coverSize.height;
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

- (void)initBottomView {
	static const CGFloat kCoverHeight 				= 163;
	static const CGFloat kCoverMarginTop 			= 35;

	static const CGFloat kMusicNameMarginTop 		= kCoverMarginTop + kCoverHeight + 20;
	static const CGFloat kMusicNameHeight 			= 20;

	static const CGFloat kSharerMarginTop 			= kMusicNameMarginTop + kMusicNameHeight + 5;

	static const CGFloat kNoteMarginTop 			= kSharerMarginTop - 3;
	static const CGFloat kNoteHeight 				= 40;

	static const CGFloat kBottomViewMarginTop 		= kNoteMarginTop + kNoteHeight + 5;
	static const CGFloat kBottomViewHeight 			= 35;

	static const CGFloat kCommentTitleHeight			= 20;
	static const CGFloat kCommentTitleWidth				= 50;
	static const CGFloat kCommentTitleMarginTop			= kBottomViewMarginTop + kBottomViewHeight + 10;
	static const CGFloat kCommentTitleMarginLeft		= 15;

	_bottomView = [[UIView alloc] initWithFrame:CGRectMake(0,
														   kBottomViewMarginTop,
														   self.bounds.size.width,
														   kBottomViewHeight)];
	//_bottomView.backgroundColor = [UIColor greenColor];
	[self addSubview:_bottomView];

	UIView *infoView = [[UIView alloc] init];
	//infoView.backgroundColor = [UIColor redColor];
	[_bottomView addSubview:infoView];

	UIView *collectionHeaderView = [[UIView alloc] init];
	//collectionHeaderView.backgroundColor = [UIColor yellowColor];
	[_bottomView addSubview:collectionHeaderView];

	static const CGFloat kBottomButtonMarginBottom		= 5;
	static const CGFloat kBottomButtonWidth				= 15;
	static const CGFloat kBottomButtonHeight			= 15;
	static const CGFloat kCommentImageMarginLeft		= 20;
	static const CGFloat kViewsImageMarginLeft			= 60;
	static const CGFloat kLocationImageMarginRight		= 1;
	static const CGFloat kLocationLabelMarginRight		= 20;
	static const CGFloat kLocationLabelWidth			= 80;

	static const CGFloat kCommentLabelMarginLeft		= 2;
	static const CGFloat kBottomLabelMarginBottom		= 5;
	static const CGFloat kBottomLabelHeight				= 15;
	static const CGFloat kCommentLabelWidth				= 20;

	static const CGFloat kViewsLabelMarginLeft			= 2;
	static const CGFloat kViewsLabelWidth				= 20;

	UIImageView *commentsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kCommentImageMarginLeft,
																				   _bottomView.bounds.size.height - kBottomButtonMarginBottom - kBottomButtonHeight,
																				   kBottomButtonWidth,
																				   kBottomButtonHeight)];
	[commentsImageView setImage:[UIImage imageNamed:@"comments"]];
	[infoView addSubview:commentsImageView];

	_commentLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kCommentImageMarginLeft + kBottomButtonWidth + kCommentLabelMarginLeft,
															  infoView.bounds.size.height - kBottomLabelMarginBottom - kBottomLabelHeight,
															  kCommentLabelWidth,
															  kBottomLabelHeight)
											  text:@""
											  font:UIFontFromSize(10.0f)
										 textColor:[UIColor grayColor]
									 textAlignment:NSTextAlignmentLeft
									   numberLines:1];
	//commentLabel.backgroundColor = [UIColor redColor];
	[infoView addSubview:_commentLabel];

	UIImageView *viewsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kViewsImageMarginLeft,
																				infoView.bounds.size.height - kBottomButtonMarginBottom - kBottomButtonHeight,
																				kBottomButtonWidth,
																				kBottomButtonHeight)];
	[viewsImageView setImage:[UIImage imageNamed:@"views"]];
	[infoView addSubview:viewsImageView];

	_viewsLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kViewsImageMarginLeft + kBottomButtonWidth + kViewsLabelMarginLeft,
															infoView.bounds.size.height - kBottomLabelMarginBottom - kBottomLabelHeight,
															kViewsLabelWidth,
															kBottomLabelHeight)
											text:@""
											font:UIFontFromSize(10.0f)
									   textColor:[UIColor grayColor]
								   textAlignment:NSTextAlignmentLeft
									 numberLines:1];
	//viewsLabel.backgroundColor = [UIColor redColor];
	[infoView addSubview:_viewsLabel];

	UIImageView *locationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(infoView.bounds.size.width - kLocationLabelMarginRight - kLocationLabelWidth - kLocationImageMarginRight - kBottomButtonWidth,
																				   infoView.bounds.size.height - kBottomButtonMarginBottom - kBottomButtonHeight,
																				   kBottomButtonWidth,
																				   kBottomButtonHeight)];
	[locationImageView setImage:[UIImage imageNamed:@"location"]];
	[infoView addSubview:locationImageView];

	_locationLabel = [[MIALabel alloc] initWithFrame:CGRectMake(infoView.bounds.size.width - kLocationLabelMarginRight - kLocationLabelWidth,
															   infoView.bounds.size.height - kBottomLabelMarginBottom - kBottomLabelHeight,
															   kLocationLabelWidth,
															   kBottomLabelHeight)
											   text:@""
											   font:UIFontFromSize(10.0f)
									   textColor:[UIColor grayColor]
								   textAlignment:NSTextAlignmentLeft
									 numberLines:1];
	//locationLabel.backgroundColor = [UIColor redColor];
	[infoView addSubview:_locationLabel];

	// TODO linyehui
	MIALabel *commentTitleLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kCommentTitleMarginLeft,
																			 kCommentTitleMarginTop,
																			 kCommentTitleWidth,
																			 kCommentTitleHeight)
															 text:@"评论"
															 font:UIFontFromSize(12.0f)
														textColor:UIColorFromHex(@"949494", 1.0)
													textAlignment:NSTextAlignmentLeft
													  numberLines:1];
	//commentTitleLabel.backgroundColor = [UIColor redColor];
	[collectionHeaderView addSubview:commentTitleLabel];

	[_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.mas_left).offset(30);
		make.right.equalTo(self.mas_right).offset(-30);
		make.bottom.equalTo(self.mas_bottom);
	}];
	[infoView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_bottomView.mas_left);
		make.right.equalTo(_bottomView.mas_right);
		make.top.equalTo(_bottomView.mas_top);
		make.bottom.equalTo(collectionHeaderView.mas_top).offset(-20);
		make.height.equalTo(@20);
	}];
	[collectionHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_bottomView.mas_left);
		make.right.equalTo(_bottomView.mas_right);
		make.top.equalTo(infoView.mas_bottom).offset(20);
		make.bottom.equalTo(_bottomView.mas_bottom);
	}];

	// infoView items
	static const CGFloat kBottomButtonSize = 12;
	[commentsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(infoView.mas_centerY);
		make.left.equalTo(infoView.mas_left);
		make.size.mas_equalTo(CGSizeMake(kBottomButtonSize, kBottomButtonSize));
	}];
	[_commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(commentsImageView.mas_right).offset(5);
		make.centerY.equalTo(infoView.mas_centerY);
//		make.top.equalTo(infoView.mas_bottom);
//		make.bottom.equalTo(infoView.mas_bottom);
		make.width.greaterThanOrEqualTo(@15);
	}];
	[viewsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_commentLabel.mas_right).offset(15);
		make.centerY.equalTo(infoView.mas_centerY);
		make.size.mas_equalTo(CGSizeMake(kBottomButtonSize, kBottomButtonSize));
	}];
	[_viewsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(viewsImageView.mas_right).offset(5);
		make.centerY.equalTo(infoView.mas_centerY);
		make.width.greaterThanOrEqualTo(@15);
	}];

	[_locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.right.equalTo(infoView.mas_right);
		make.centerY.equalTo(infoView.mas_centerY);
		make.width.greaterThanOrEqualTo(@15);
	}];

	[locationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.right.equalTo(_locationLabel.mas_left).offset(-5);
		make.centerY.equalTo(infoView.mas_centerY);
		make.size.mas_equalTo(CGSizeMake(kBottomButtonSize, kBottomButtonSize));
	}];

	[commentTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(collectionHeaderView.mas_left);
		make.right.equalTo(collectionHeaderView.mas_right);
		make.top.equalTo(collectionHeaderView.mas_top);
		make.bottom.equalTo(collectionHeaderView.mas_bottom);
	}];

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
	[_noteLabel setText:[item sNote]];

	[_commentLabel setText: 0 == [item cComm] ? @"" : NSStringFromInt([item cComm])];
	[_viewsLabel setText: 0 == [item cView] ? @"" : NSStringFromInt([item cView])];
	[_locationLabel setText:[item sAddress]];

	[self updateShareButtonWithIsFavorite:item.favorite];
}

- (void)updateShareButtonWithIsFavorite:(BOOL)isFavorite {
	if (isFavorite) {
		[_favoriteButton setImage:[UIImage imageNamed:@"favorite_red"] forState:UIControlStateNormal];
	} else {
		[_favoriteButton setImage:[UIImage imageNamed:@"favorite_white"] forState:UIControlStateNormal];
	}
}

#pragma mark - notification

- (void)notificationMusicPlayerMgrDidPlay:(NSNotification *)notification {
	[_playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
	_progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
}

- (void)notificationMusicPlayerMgrDidPause:(NSNotification *)notification {
	[_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
	[_progressTimer invalidate];
}

- (void)notificationMusicPlayerMgrCompletion:(NSNotification *)notification {
	[_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
	[_progressTimer invalidate];
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
	if ([[UserSession standard] isLogined]) {
		NSLog(@"favorite to profile page.");

		[MiaAPIHelper favoriteMusicWithShareID:_shareItem.sID isFavorite:!_shareItem.favorite];
	} else {
		[_customDelegate detailHeaderViewShouldLogin];
	}
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
