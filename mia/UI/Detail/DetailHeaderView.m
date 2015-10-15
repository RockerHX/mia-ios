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

static const CGFloat kCoverWidth 				= 163;
static const CGFloat kCoverHeight 				= 163;

@interface DetailHeaderView()
@end

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

	UIView			*_infectUsersView;

	UIView 			*_bottomView;
	MIALabel 		*_commentLabel;
	MIALabel 		*_viewsLabel;
	MIALabel 		*_locationLabel;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self){
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
	_coverImageView = [[UIImageView alloc] init];

	[self initCoverView:_coverImageView];
	[self initSongView];
	[self initNoteView];
	[self initBottomView];

	[_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.mas_centerX);
		make.size.mas_equalTo(CGSizeMake(kCoverWidth, kCoverHeight));
		make.top.equalTo(self.mas_top).with.offset(35);
	}];
}

- (void)initCoverView:(UIImageView *)contentView {


	contentView.layer.borderWidth = 0.5f;
	contentView.layer.borderColor = UIColorFromHex(@"a2a2a2", 1.0).CGColor;

	[contentView sd_setImageWithURL:nil
					   placeholderImage:[UIImage imageNamed:@"default_cover"]];
	[self addSubview:contentView];

	_playButton = [[MIAButton alloc] initWithFrame:CGRectZero
									   titleString:nil
										titleColor:nil
											  font:nil
										   logoImg:nil
								   backgroundImage:nil];
	[_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
	[_playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_playButton];

	[_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.size.mas_equalTo(CGSizeMake(35, 35));
		make.centerX.equalTo(contentView.mas_centerX);
		make.centerY.equalTo(contentView.mas_centerY);
//		make.right.equalTo(contentView.mas_right).with.offset(-12);
//		make.bottom.equalTo(contentView.mas_bottom).with.offset(-12);
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
	[_sharerLabel setUserInteractionEnabled:YES];
	[_sharerLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sharerLabelTouchAction:)]];
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
		make.height.equalTo(_noteLabel.mas_height);
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

- (void)initBottomView {
	_bottomView = [[UIView alloc] init];
	//_bottomView.backgroundColor = [UIColor greenColor];
	[self addSubview:_bottomView];

	UIView *infoView = [[UIView alloc] init];
	//infoView.backgroundColor = [UIColor redColor];
	[_bottomView addSubview:infoView];

	UIView *collectionHeaderView = [[UIView alloc] init];
	//collectionHeaderView.backgroundColor = [UIColor yellowColor];
	[_bottomView addSubview:collectionHeaderView];

	UIImageView *commentsImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[commentsImageView setImage:[UIImage imageNamed:@"comments"]];
	[infoView addSubview:commentsImageView];

	_commentLabel = [[MIALabel alloc] initWithFrame:CGRectZero
											  text:@""
											  font:UIFontFromSize(10.0f)
										 textColor:[UIColor grayColor]
									 textAlignment:NSTextAlignmentLeft
									   numberLines:1];
	//commentLabel.backgroundColor = [UIColor redColor];
	[infoView addSubview:_commentLabel];

	UIImageView *viewsImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[viewsImageView setImage:[UIImage imageNamed:@"views"]];
	[infoView addSubview:viewsImageView];

	_viewsLabel = [[MIALabel alloc] initWithFrame:CGRectZero
											text:@""
											font:UIFontFromSize(10.0f)
									   textColor:[UIColor grayColor]
								   textAlignment:NSTextAlignmentLeft
									 numberLines:1];
	//viewsLabel.backgroundColor = [UIColor redColor];
	[infoView addSubview:_viewsLabel];

	UIImageView *locationImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[locationImageView setImage:[UIImage imageNamed:@"location"]];
	[infoView addSubview:locationImageView];

	_locationLabel = [[MIALabel alloc] initWithFrame:CGRectZero
											   text:@""
											   font:UIFontFromSize(10.0f)
									   textColor:[UIColor grayColor]
								   textAlignment:NSTextAlignmentLeft
									 numberLines:1];
	//locationLabel.backgroundColor = [UIColor redColor];
	[infoView addSubview:_locationLabel];

	MIALabel *commentTitleLabel = [[MIALabel alloc] initWithFrame:CGRectZero
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
	[_musicArtistLabel setText:[[NSString alloc] initWithFormat:@"  %@", [[item music] singerName]]];
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

#pragma mark - delegate 


#pragma mark - notification

- (void)notificationMusicPlayerMgrDidPlay:(NSNotification *)notification {
	[_playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
}

- (void)notificationMusicPlayerMgrDidPause:(NSNotification *)notification {
	[_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
}

- (void)notificationMusicPlayerMgrCompletion:(NSNotification *)notification {
	[_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
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
	if (_customDelegate) {
		[_customDelegate detailHeaderViewClickedFavoritor];
	}

	[self updateShareButtonWithIsFavorite:!_shareItem.favorite];
}

- (void)sharerLabelTouchAction:(id)sender {
	if (_customDelegate) {
		[_customDelegate detailHeaderViewClickedSharer];
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

@end
