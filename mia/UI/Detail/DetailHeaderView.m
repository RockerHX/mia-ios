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
#import "InfectUserItem.h"

static const CGFloat kCoverWidth 				= 163;
static const CGFloat kCoverHeight 				= 163;
static const CGFloat kInfectUserAvatarSize		= 22;

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
	UIImageView 	*_commentsImageView;

	long			_lastInfectUsersCount;
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
//	self.backgroundColor = [UIColor blueColor];
	_coverImageView = [[UIImageView alloc] init];
	[self addSubview:_coverImageView];

	_songView = [[UIView alloc] init];
	//songView.backgroundColor = [UIColor greenColor];
	[self addSubview:_songView];

	_noteView = [[UIView alloc] init];
//	_noteView.backgroundColor = [UIColor greenColor];
	[self addSubview:_noteView];

	_infectUsersView = [[UIView alloc] init];
//	_infectUsersView.backgroundColor = [UIColor yellowColor];
	[self addSubview:_infectUsersView];

	_bottomView = [[UIView alloc] init];
//	_bottomView.backgroundColor = UIColorFromHex(@"00ff00", 0.8);
	[self addSubview:_bottomView];

	[self initCoverView:_coverImageView];
	[self initSongView:_songView];
	[self initNoteView:_noteView];
	[self initBottomView:_bottomView];

	[self mas_updateConstraints:^(MASConstraintMaker *make) {
		make.bottom.equalTo(_bottomView.mas_bottom);
	}];

	[_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.mas_centerX);
		make.size.mas_equalTo(CGSizeMake(kCoverWidth, kCoverHeight));
		make.top.equalTo(self.mas_top).with.offset(35);
	}];

	[_songView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.mas_centerX);
		make.top.equalTo(_coverImageView.mas_bottom).with.offset(20);
		make.width.lessThanOrEqualTo(self.mas_width);
	}];

	[_noteView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(_songView.mas_bottom).with.offset(20);
		make.height.equalTo(_noteLabel.mas_height);
		make.left.equalTo(self.mas_left).with.offset(30);
		make.right.equalTo(self.mas_right).with.offset(-30);
	}];

	[_infectUsersView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(_noteView.mas_bottom).with.offset(20);
		make.height.mas_equalTo(kInfectUserAvatarSize);
		make.centerX.mas_equalTo(self.mas_centerX);
	}];
}

- (void)initCoverView:(UIImageView *)contentView {


	contentView.layer.borderWidth = 0.5f;
	contentView.layer.borderColor = UIColorFromHex(@"a2a2a2", 1.0).CGColor;

	[contentView sd_setImageWithURL:nil
					   placeholderImage:[UIImage imageNamed:@"default_cover"]];

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

- (void)initSongView:(UIView *)contentView {
	_musicNameLabel = [[MIALabel alloc] initWithFrame:CGRectZero
												 text:@""
												 font:UIFontFromSize(9.0f)
											textColor:[UIColor blackColor]
										textAlignment:NSTextAlignmentLeft
										  numberLines:1];
	[contentView addSubview:_musicNameLabel];

	_musicArtistLabel = [[MIALabel alloc] initWithFrame:CGRectZero
												   text:@""
												   font:UIFontFromSize(8.0f)
										   textColor:UIColorFromHex(@"a2a2a2", 1.0)
									   textAlignment:NSTextAlignmentLeft
								   numberLines:1];
	[contentView addSubview:_musicArtistLabel];

	_favoriteButton = [[MIAButton alloc] initWithFrame:CGRectZero
										   titleString:nil
											titleColor:nil
												  font:nil
											   logoImg:nil
									   backgroundImage:nil];
	[_favoriteButton setImage:[UIImage imageNamed:@"favorite_normal"] forState:UIControlStateNormal];
	[_favoriteButton addTarget:self action:@selector(favoriteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[contentView addSubview:_favoriteButton];

	[_musicNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(contentView.mas_left);
		make.right.equalTo(_musicArtistLabel.mas_left);
		make.top.equalTo(contentView.mas_top);
		make.bottom.equalTo(contentView.mas_bottom);
	}];
	[_musicArtistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_musicNameLabel.mas_right);
		make.right.equalTo(_favoriteButton.mas_left).with.offset(-15);
		make.top.equalTo(contentView.mas_top);
		make.bottom.equalTo(contentView.mas_bottom);
	}];
	[_favoriteButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_musicArtistLabel.mas_right).with.offset(15);
		make.right.equalTo(contentView.mas_right);
		make.size.mas_equalTo(CGSizeMake(15, 15));
		make.centerY.equalTo(contentView.mas_centerY);
	}];
}

- (void)initNoteView:(UIView *)contentView {
	_sharerLabel = [[MIALabel alloc] initWithFrame:CGRectZero
											  text:@""
											  font:UIFontFromSize(9.0f)
										 textColor:[UIColor blueColor]
									 textAlignment:NSTextAlignmentRight
									   numberLines:1];
	//_sharerLabel.backgroundColor = [UIColor yellowColor];
	[_sharerLabel setUserInteractionEnabled:YES];
	[_sharerLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sharerLabelTouchAction:)]];
	[contentView addSubview:_sharerLabel];

	_noteLabel = [[MIALabel alloc] initWithFrame:CGRectZero
											  text:@""
											  font:UIFontFromSize(9.0f)
										 textColor:[UIColor blackColor]
									 textAlignment:NSTextAlignmentLeft
									   numberLines:0];
	//_noteLabel.backgroundColor = [UIColor redColor];
	[contentView addSubview:_noteLabel];

	[_sharerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(contentView.mas_left);
		make.top.equalTo(contentView.mas_top);
		make.width.greaterThanOrEqualTo(@30);
		make.width.lessThanOrEqualTo(@60);
	}];
	[_noteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_sharerLabel.mas_right).with.offset(2);
		make.right.equalTo(contentView.mas_right);
		make.top.equalTo(contentView.mas_top);
	}];
}

- (void)initBottomView:(UIView *)contentView {
	UIImageView *viewsImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[viewsImageView setImage:[UIImage imageNamed:@"views"]];
	[contentView addSubview:viewsImageView];

	_viewsLabel = [[MIALabel alloc] initWithFrame:CGRectZero
											text:@""
											font:UIFontFromSize(10.0f)
									   textColor:[UIColor grayColor]
								   textAlignment:NSTextAlignmentLeft
									 numberLines:1];
//	_viewsLabel.backgroundColor = [UIColor redColor];
	[contentView addSubview:_viewsLabel];

	UIImageView *locationImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[locationImageView setImage:[UIImage imageNamed:@"location"]];
	[contentView addSubview:locationImageView];

	_locationLabel = [[MIALabel alloc] initWithFrame:CGRectZero
											   text:@""
											   font:UIFontFromSize(10.0f)
									   textColor:[UIColor grayColor]
								   textAlignment:NSTextAlignmentLeft
									 numberLines:1];
	//locationLabel.backgroundColor = [UIColor redColor];
	[contentView addSubview:_locationLabel];

	UIView *lineView = [[UIView alloc] init];
	lineView.backgroundColor = UIColorFromHex(@"eaeaea", 1.0);
	[contentView addSubview:lineView];

	_commentsImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[_commentsImageView setImage:[UIImage imageNamed:@"comments"]];
	[contentView addSubview:_commentsImageView];

	_commentLabel = [[MIALabel alloc] initWithFrame:CGRectZero
											   text:@""
											   font:UIFontFromSize(10.0f)
										  textColor:[UIColor grayColor]
									  textAlignment:NSTextAlignmentLeft
										numberLines:1];
	//commentLabel.backgroundColor = [UIColor redColor];
	[contentView addSubview:_commentLabel];

	// ----------------------- auto layout -----------------------

	[_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(_infectUsersView.mas_bottom).offset(10);
		make.left.equalTo(self.mas_left);
		make.right.equalTo(self.mas_right);
		make.bottom.equalTo(_commentsImageView.mas_bottom);
	}];

	// infoView items
	static const CGFloat kBottomButtonSize = 12;
	[viewsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(contentView.mas_top);
		make.left.equalTo(contentView.mas_left).offset(10);
		make.size.mas_equalTo(CGSizeMake(kBottomButtonSize, kBottomButtonSize));
	}];
	[_viewsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(viewsImageView.mas_right).offset(5);
		make.top.equalTo(contentView.mas_top);
		make.width.greaterThanOrEqualTo(@15);
	}];

	[_locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.right.equalTo(contentView.mas_right).offset(-15);
		make.top.equalTo(contentView.mas_top);
		make.width.greaterThanOrEqualTo(@15);
	}];

	[locationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.right.equalTo(_locationLabel.mas_left).offset(-5);
		make.top.equalTo(contentView.mas_top);
		make.size.mas_equalTo(CGSizeMake(kBottomButtonSize, kBottomButtonSize));
	}];

	// title view
	[lineView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@0.5);
		make.left.equalTo(contentView.mas_left);
		make.right.equalTo(contentView.mas_right);
		make.top.equalTo(locationImageView.mas_bottom).offset(5);
	}];
	[_commentsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(lineView.mas_bottom).offset(5);
		make.left.equalTo(contentView.mas_left).offset(10);
		make.size.mas_equalTo(CGSizeMake(kBottomButtonSize, kBottomButtonSize));
	}];
	[_commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_commentsImageView.mas_right).offset(5);
		make.width.greaterThanOrEqualTo(@15);
		make.top.equalTo(_commentsImageView.mas_top);
		make.bottom.equalTo(_commentsImageView.mas_bottom);
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

	[self updateInfectUsers];
}

- (void)updateShareButtonWithIsFavorite:(BOOL)isFavorite {
	if (isFavorite) {
		[_favoriteButton setImage:[UIImage imageNamed:@"favorite_red"] forState:UIControlStateNormal];
	} else {
		[_favoriteButton setImage:[UIImage imageNamed:@"favorite_white"] forState:UIControlStateNormal];
	}
}

- (void)updateInfectUsers {
	long currentUsersCount = [_shareItem.infectUsers count];
	// 判断是否需要刷新布局
	BOOL isNeedUpdateLayout = YES;
	if ((_lastInfectUsersCount == 0 && currentUsersCount == 0)
		|| (_lastInfectUsersCount > 0 && currentUsersCount > 0)) {
		isNeedUpdateLayout = NO;
	}

	if (currentUsersCount > 0) {
		for (UIView *subView in _infectUsersView.subviews) {
			[subView removeFromSuperview];
		}

		UIView *prevView = nil;
		for (long i = 0; i < currentUsersCount; i++) {
			InfectUserItem *item = _shareItem.infectUsers[i];

			UIImageView *imageView = [[UIImageView alloc] init];
			imageView.layer.cornerRadius = kInfectUserAvatarSize / 2;
			imageView.clipsToBounds = YES;
			imageView.layer.borderWidth = 1.0f;
			imageView.layer.borderColor = UIColorFromHex(@"a2a2a2", 1.0).CGColor;
			[imageView sd_setImageWithURL:[NSURL URLWithString:item.avatar] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
			[_infectUsersView addSubview:imageView];
			[imageView mas_makeConstraints:^(MASConstraintMaker *make) {
				if (nil == prevView) {
					make.left.equalTo(_infectUsersView.mas_left);
				} else {
					make.left.equalTo(prevView.mas_right).offset(5);
				}

				make.size.mas_equalTo(CGSizeMake(kInfectUserAvatarSize, kInfectUserAvatarSize));
				make.centerY.equalTo(_infectUsersView.mas_centerY);
			}];
			prevView = imageView;
		} // for

		MIALabel *coutLabel = [[MIALabel alloc] initWithFrame:CGRectZero
														 text:[NSString stringWithFormat:@"妙推 %d", _shareItem.infectTotal]
														 font:UIFontFromSize(9.0f)
													textColor:UIColorFromHex(@"a2a2a2", 1.0)
												textAlignment:NSTextAlignmentLeft
												  numberLines:1];
		[_infectUsersView addSubview:coutLabel];
		[coutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(prevView.mas_right).offset(5);
			make.width.greaterThanOrEqualTo(@30);
			make.centerY.equalTo(_infectUsersView.mas_centerY);
			make.right.equalTo(_infectUsersView.mas_right);
		}];
		[_infectUsersView mas_updateConstraints:^(MASConstraintMaker *make) {
			make.right.equalTo(coutLabel.mas_right);
		}];
	}

	if (isNeedUpdateLayout) {
		[self updateLayoutForInfectUsers];
	}

	_lastInfectUsersCount = currentUsersCount;
}

- (void)updateLayoutForInfectUsers {
	if ([_shareItem.infectUsers count] > 0) {
		[_infectUsersView setHidden:NO];
		[_bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
			make.top.equalTo(_infectUsersView.mas_bottom).offset(10);
			make.left.equalTo(self.mas_left);
			make.right.equalTo(self.mas_right);
			make.bottom.equalTo(_commentsImageView.mas_bottom);
		}];
	} else {
		[_infectUsersView setHidden:YES];
		[_bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
			make.top.equalTo(_noteView.mas_bottom).with.offset(10);
			make.left.equalTo(self.mas_left);
			make.right.equalTo(self.mas_right);
			make.bottom.equalTo(_commentsImageView.mas_bottom);
		}];
	}
	[self layoutIfNeeded];

	if (_customDelegate) {
		[_customDelegate detailHeaderViewChangeHeight];
	}
}

#pragma mark - delegate 


#pragma mark - notification

- (void)notificationMusicPlayerMgrDidPlay:(NSNotification *)notification {
	long modelID = [[notification userInfo][MusicPlayerMgrNotificationKey_ModelID] longValue];
	if (modelID != (long)(__bridge void *)self) {
		NSLog(@"skip other model's notification: MusicPlayerMgrDidPlay");
		return;
	}

	[_playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
}

- (void)notificationMusicPlayerMgrDidPause:(NSNotification *)notification {
	long modelID = [[notification userInfo][MusicPlayerMgrNotificationKey_ModelID] longValue];
	if (modelID != (long)(__bridge void *)self) {
		NSLog(@"skip other model's notification: notificationMusicPlayerMgrDidPause");
		return;
	}

	[_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
}

- (void)notificationMusicPlayerMgrCompletion:(NSNotification *)notification {
	long modelID = [[notification userInfo][MusicPlayerMgrNotificationKey_ModelID] longValue];
	if (modelID != (long)(__bridge void *)self) {
		NSLog(@"skip other model's notification: notificationMusicPlayerMgrCompletion");
		return;
	}

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

	[[MusicPlayerMgr standard] playWithModelID:(long)(__bridge void *)self url:musicUrl title:musicTitle artist:musicArtist];
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
