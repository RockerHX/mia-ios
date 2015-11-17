//
//  ProfileHeaderView.m
//  mia
//
//  Created by linyehui on 2015/09/09.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "ProfileHeaderView.h"
#import "MIALabel.h"
#import "MIAButton.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+BlurredImage.h"
#import "UIImage+Extrude.h"
#import "FavoriteMgr.h"
#import "FavoriteItem.h"
#import "Masonry.h"
#import "UserSession.h"

static const CGFloat kProfileHeaderHeight 					= 240;
static const CGFloat kProfileHeaderHeightWithNotification 	= 295;

@implementation ProfileHeaderView {
	UIView		*_notificationView;
	UIImageView	*_avatarImageView;
	MIALabel	*_notificationCountLabel;

	UIView		*_infoView;
	UIView 		*_coverView;
	UIImageView *_coverImageView;
	NSString	*_coverImageUrl;

	MIAButton	*_playButton;
	MIALabel 	*_favoriteCountLabel;
	MIALabel 	*_cachedCountLabel;
	MIALabel 	*_wifiTipsLabel;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self) {
		[self initUI];
	}

	return self;
}

+ (CGFloat)headerHeight {
	int unreadCommentCount = [[[UserSession standard] unreadCommCnt] intValue];
	if (unreadCommentCount > 0) {
		return kProfileHeaderHeightWithNotification;
	} else {
		return kProfileHeaderHeight;
	}
}

- (BOOL)hasNotification {
	int unreadCommentCount = [[[UserSession standard] unreadCommCnt] intValue];
	return (unreadCommentCount > 0);
}

#pragma mark - Private Meghtods
- (void)initUI {
	_notificationView = [[UIView alloc] init];
	[self addSubview:_notificationView];
	[self initNotificationView:_notificationView];

	_infoView = [[UIView alloc] init];
	[self addSubview:_infoView];
	[self initInfoView:_infoView];

	[_notificationView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@45);
		make.top.equalTo(self.mas_top).offset(15);
		make.centerX.equalTo(self.mas_centerX);
	}];
	[self updateConstraintsWithNotification:_hasNotification];
}

- (void)updateConstraintsWithNotification:(BOOL)hasNotification {
	if (hasNotification) {
		[_notificationView setHidden:NO];

		[_infoView mas_remakeConstraints:^(MASConstraintMaker *make) {
			make.height.equalTo(@240);
			make.left.equalTo(self.mas_left);
			make.right.equalTo(self.mas_right);
			make.top.equalTo(_notificationView.mas_bottom).offset(5);
		}];
	} else {
		[_notificationView setHidden:YES];

		[_infoView mas_remakeConstraints:^(MASConstraintMaker *make) {
			make.height.equalTo(@240);
			make.left.equalTo(self.mas_left);
			make.right.equalTo(self.mas_right);
			make.top.equalTo(self.mas_top).offset(0);
		}];
	}
}

- (void)initNotificationView:(UIView *)contentView {
	contentView.backgroundColor = UIColorFromHex(@"0bd0bc", 1.0);
	contentView.layer.cornerRadius = 10;
	contentView.clipsToBounds = YES;

	static CGFloat kAvatarWidth = 27;
	_avatarImageView = [[UIImageView alloc] init];
	_avatarImageView.layer.cornerRadius = kAvatarWidth / 2;
	_avatarImageView.clipsToBounds = YES;
//	_avatarImageView.layer.borderWidth = 0.5f;
//	_avatarImageView.layer.borderColor = UIColorFromHex(@"808080", 1.0).CGColor;
	[_avatarImageView setImage:[UIImage imageNamed:@"HP-InfectUserDefaultHeader"]];
	[contentView addSubview:_avatarImageView];

	_notificationCountLabel = [[MIALabel alloc] initWithFrame:CGRectZero
															text:@"10条新消息"
															font:UIFontFromSize(16.0f)
													textColor:[UIColor whiteColor]
												textAlignment:NSTextAlignmentLeft
													 numberLines:1];
	[contentView addSubview:_notificationCountLabel];

	[_avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.size.mas_equalTo(CGSizeMake(kAvatarWidth, kAvatarWidth));
		make.centerY.equalTo(contentView.mas_centerY);
		make.left.equalTo(contentView.mas_left).offset(20);
	}];

	[_notificationCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(contentView.mas_centerY);
		make.left.equalTo(_avatarImageView.mas_right).offset(15);
		make.right.equalTo(contentView.mas_right).offset(-20);
	}];

}

- (void)initInfoView:(UIView *)contentView {
	_coverView = [[UIView alloc] init];
	[self initCoverView:_coverView];
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverMaskTouchAction:)];
	[_coverView addGestureRecognizer:tap];
	[contentView addSubview:_coverView];

	UIView *favoriteTitleView = [[UIView alloc] init];
	[contentView addSubview:favoriteTitleView];
	[self initFavoriteTitle:favoriteTitleView];

	UIView *shareTitleView = [[UIView alloc] init];
	[contentView addSubview:shareTitleView];
	[self initShareTitle:shareTitleView];

	[_coverView mas_remakeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@160);
		make.left.equalTo(contentView.mas_left);
		make.right.equalTo(contentView.mas_right);
		make.top.equalTo(contentView.mas_top).offset(40);
	}];

	[favoriteTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@40);
		make.top.equalTo(contentView.mas_top);
		make.left.equalTo(contentView.mas_left).offset(15);
	}];

	[shareTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@40);
		make.bottom.equalTo(contentView.mas_bottom);
		make.left.equalTo(contentView.mas_left).offset(15);
	}];
}

- (void)initCoverView:(UIView *)contentView {
	_coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 160)];
	[_coverImageView setImage:[UIImage imageNamed:@"profile_default_cover"]];
	[contentView addSubview:_coverImageView];

	UIImageView *coverMaskImageView = [[UIImageView alloc] initWithFrame:contentView.bounds];
	[coverMaskImageView setImage:[UIImage imageNamed:@"profile_banner_mask"]];
	[contentView addSubview:coverMaskImageView];

	UIView *cacheInfoView = [[UIView alloc] init];
//	cacheInfoView.backgroundColor = [UIColor redColor];
	[contentView addSubview:cacheInfoView];
	[self initCacheInfoView:cacheInfoView];
	[cacheInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(contentView.mas_centerX);
		make.centerY.equalTo(contentView.mas_centerY);
	}];

	_wifiTipsLabel = [[MIALabel alloc] initWithFrame:CGRectZero
												text:@"在非WIFI网络下，播放收藏歌曲不产生任何流量"
												font:UIFontFromSize(14.0f)
										   textColor:[UIColor whiteColor]
									   textAlignment:NSTextAlignmentCenter
										 numberLines:1];
	[contentView addSubview:_wifiTipsLabel];
	[_wifiTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.bottom.equalTo(contentView.mas_bottom).offset(-10);
		make.centerX.equalTo(contentView.mas_centerX);
	}];

}

- (void)initCacheInfoView:(UIView *)contentView {
	_favoriteCountLabel = [[MIALabel alloc] initWithFrame:CGRectZero
													 text:[NSString stringWithFormat:@"%ld", [[FavoriteMgr standard] favoriteCount]]
													 font:UIFontFromSize(52)
												textColor:[UIColor whiteColor]
											textAlignment:NSTextAlignmentRight
											  numberLines:1];
//	_favoriteCountLabel.backgroundColor = [UIColor blueColor];
	[contentView addSubview:_favoriteCountLabel];
	MIALabel *favoriteMiddleLabel = [[MIALabel alloc] initWithFrame:CGRectZero
															   text:@"首收藏歌曲"
															   font:UIFontFromSize(18.0f)
														  textColor:[UIColor whiteColor]
													  textAlignment:NSTextAlignmentRight
														numberLines:1];
//	favoriteMiddleLabel.backgroundColor = [UIColor greenColor];
	[contentView addSubview:favoriteMiddleLabel];

	_cachedCountLabel = [[MIALabel alloc] initWithFrame:CGRectZero
															text:[NSString stringWithFormat:@"%ld首已下载到本地", [[FavoriteMgr standard] cachedCount]]
															font:UIFontFromSize(14.0f)
											  textColor:[UIColor whiteColor]
										  textAlignment:NSTextAlignmentLeft
											numberLines:1];
//	_cachedCountLabel.backgroundColor = [UIColor greenColor];
	[contentView addSubview:_cachedCountLabel];

	_playButton = [[MIAButton alloc] initWithFrame:CGRectZero
									   titleString:nil
										titleColor:nil
											  font:nil
										   logoImg:nil
								   backgroundImage:nil];
	[_playButton setBackgroundImage:[UIImage imageNamed:@"M-PlayIcon"] forState:UIControlStateNormal];
//	_playButton.backgroundColor = [UIColor redColor];
	[_playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[contentView addSubview:_playButton];

	[_favoriteCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(contentView.mas_left);
		make.centerY.equalTo(contentView.mas_centerY);
	}];

	[favoriteMiddleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_favoriteCountLabel.mas_right).offset(8);
		make.top.equalTo(contentView.mas_top);
	}];

	[_cachedCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_favoriteCountLabel.mas_right).offset(8);
		make.top.equalTo(favoriteMiddleLabel.mas_bottom).offset(5);
		make.bottom.equalTo(contentView.mas_bottom);
	}];

	[_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_cachedCountLabel.mas_right).offset(15);
		make.right.equalTo(contentView.mas_right);
		make.centerY.equalTo(contentView.mas_centerY);
		make.size.mas_equalTo(CGSizeMake(0, 0));
	}];
}

- (void)initFavoriteTitle:(UIView *)contentView {
	UIImageView *iconImageView = [[UIImageView alloc] init];
	[iconImageView setImage:[UIImage imageNamed:@"profile_favorite"]];
	[contentView addSubview:iconImageView];
	MIALabel *titleLabel = [[MIALabel alloc] initWithFrame:CGRectZero
														 text:@"收藏"
														 font:UIFontFromSize(14.0f)
										   textColor:UIColorFromHex(@"a2a2a2", 1.0)
									   textAlignment:NSTextAlignmentLeft
												  numberLines:1];
	[contentView addSubview:titleLabel];

	[iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.size.mas_equalTo(CGSizeMake(16, 16));
		make.centerY.equalTo(contentView.mas_centerY);
		make.left.equalTo(contentView.mas_left);
	}];

	[titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(contentView.mas_centerY);
		make.left.equalTo(iconImageView.mas_right).offset(8);
		make.right.equalTo(contentView.mas_right);
	}];
}

- (void)initShareTitle:(UIView *)contentView {
	UIImageView *iconImageView = [[UIImageView alloc] init];
	[iconImageView setImage:[UIImage imageNamed:@"share"]];
	[contentView addSubview:iconImageView];
	MIALabel *titleLabel = [[MIALabel alloc] initWithFrame:CGRectZero
														 text:@"分享"
														 font:UIFontFromSize(14.0f)
										   textColor:UIColorFromHex(@"a2a2a2", 1.0)
									   textAlignment:NSTextAlignmentLeft
												  numberLines:1];
	[contentView addSubview:titleLabel];

	[iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.size.mas_equalTo(CGSizeMake(16, 16));
		make.centerY.equalTo(contentView.mas_centerY);
		make.left.equalTo(contentView.mas_left);
	}];

	[titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(contentView.mas_centerY);
		make.left.equalTo(iconImageView.mas_right).offset(8);
		make.right.equalTo(contentView.mas_right);
	}];
}

- (void)setIsPlaying:(BOOL)isPlaying {
	_isPlaying = isPlaying;
	if (_isPlaying) {
		[_playButton setBackgroundImage:[UIImage imageNamed:@"M-PauseIcon"] forState:UIControlStateNormal];
	} else {
		[_playButton setBackgroundImage:[UIImage imageNamed:@"M-PlayIcon"] forState:UIControlStateNormal];
	}
}

- (UIImage *)getBannerImageFromCover:(UIImage *)orgImage containerSize:(CGSize)containerSize {
	CGFloat cutHeight = containerSize.height * orgImage.size.width / containerSize.width;
	if (cutHeight <= 0.0) {
		cutHeight = orgImage.size.height / 3;
	}

	CGFloat cutY = orgImage.size.height / 2 - cutHeight / 2;
	if (cutY <= 0.0) {
		cutY = 0.0;
	}

	return [orgImage getSubImage:CGRectMake(0.0,
											cutY,
											orgImage.size.width,
											cutHeight)];
}

- (void)updateFavoriteCount {
	long favoriteCount = [[FavoriteMgr standard] favoriteCount];
	[_favoriteCountLabel setText:[NSString stringWithFormat:@"%ld", favoriteCount]];
	[_cachedCountLabel setText:[NSString stringWithFormat:@"%ld首已下载到本地", [[FavoriteMgr standard] cachedCount]]];

	if (0 == favoriteCount) {
		[_cachedCountLabel setText:@"点“红心”将歌曲收入这里"];
		[_wifiTipsLabel setHidden:YES];
		[_playButton setHidden:YES];

		[_playButton mas_updateConstraints:^(MASConstraintMaker *make) {
			make.size.mas_equalTo(CGSizeMake(0, 0));
		}];
	} else {
		[_wifiTipsLabel setHidden:NO];
		[_playButton setHidden:NO];
		[_playButton mas_updateConstraints:^(MASConstraintMaker *make) {
			make.size.mas_equalTo(CGSizeMake(40, 40));
		}];
	}

	[self updateCoverImage];
}

- (void)updateCoverImage {
	if ([[FavoriteMgr standard].dataSource count] > 0) {
		FavoriteItem *item = [FavoriteMgr standard].dataSource[0];
		if ([_coverImageUrl isEqualToString:item.music.purl]) {
			return;
		}

		[_coverImageView sd_setImageWithURL:[NSURL URLWithString:item.music.purl]
						   placeholderImage:_coverImageView.image
									options:SDWebImageAvoidAutoSetImage
								  completed:
		 ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
			 if (image) {
				 UIImage *bannerImage = [self getBannerImageFromCover:image containerSize:_coverView.bounds.size];
				 [_coverImageView setImageToBlur:bannerImage blurRadius:6.0 completionBlock:nil];

				 CATransition *transition = [CATransition animation];
				 transition.duration = 0.2f;
				 transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
				 transition.type = kCATransitionFade;
				 [_coverImageView.layer addAnimation:transition forKey:nil];
			 }
		 }];
	}
}

#pragma mark - button Actions

- (void)playButtonAction:(id)sender {
	[_profileHeaderViewDelegate profileHeaderViewDidTouchedPlay];
}

- (void)coverMaskTouchAction:(id)sender {
	[_profileHeaderViewDelegate profileHeaderViewDidTouchedCover];
}

@end
