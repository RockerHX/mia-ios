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


@implementation ProfileHeaderView {
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self){
		[self initUI];

	}

	return self;
}

- (void)initUI {
	static const CGFloat kCoverMarginTop = 44;
	static const CGFloat kPlayButtonMarginRight = 76;
	static const CGFloat kPlayButtonMarginTop = 109;
	static const CGFloat kPlayButtonWidth = 40;

	CGRect coverFrame = CGRectMake(0,
								   kCoverMarginTop,
								   self.frame.size.width,
								   self.frame.size.height - kCoverMarginTop * 2);
	UIImageView *coverImageView = [[UIImageView alloc] initWithFrame:coverFrame];
	//[coverImageView setImage:[UIImage imageNamed:@"default_cover"]];
	[coverImageView setImageToBlur:[UIImage imageNamed:@"default_cover"] blurRadius:6.0 completionBlock:nil];
	[self addSubview:coverImageView];
	UIImageView *coverMaskImageView = [[UIImageView alloc] initWithFrame:coverFrame];
	[coverMaskImageView setImage:[UIImage imageNamed:@"cover_mask"]];
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverMaskTouchAction:)];
	[coverMaskImageView addGestureRecognizer:tap];
	[self addSubview:coverMaskImageView];


	MIAButton *playButton = [[MIAButton alloc] initWithFrame:CGRectMake(self.frame.size.width - kPlayButtonMarginRight - kPlayButtonWidth,
																		kPlayButtonMarginTop,
																		kPlayButtonWidth,
																		kPlayButtonWidth)
												 titleString:nil
												  titleColor:nil
														font:nil
													 logoImg:nil
											 backgroundImage:nil];
	[playButton setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
	[playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:playButton];

	const static CGFloat kFavoriteCountLabelMarginRight		= 220;
	const static CGFloat kFavoriteCountLabelMarginTop		= 108;
	const static CGFloat kFavoriteCountLabelHeight			= 38;

	static const CGFloat kFavoriteMiddleLabelMarginRight 	= 120;
	static const CGFloat kFavoriteMiddleLabelMarginTop 		= 108;
	static const CGFloat kFavoriteMiddleLabelWidth 			= 100;
	static const CGFloat kFavoriteMiddleLabelHeight 		= 20;

	static const CGFloat kCachedCountLabelMarginRight 		= 120;
	static const CGFloat kCachedCountLabelMarginTop 		= 130;
	static const CGFloat kCachedCountLabelWidth 			= 100;
	static const CGFloat kCachedCountLabelHeight 			= 20;

	MIALabel *favoriteCountLabel = [[MIALabel alloc] initWithFrame:CGRectMake(0,
																			  kFavoriteCountLabelMarginTop,
																			  self.frame.size.width - kFavoriteCountLabelMarginRight,
																			  kFavoriteCountLabelHeight)
															  text:@"30"
															  font:UIFontFromSize(35.0f)
														 textColor:[UIColor whiteColor]
													 textAlignment:NSTextAlignmentRight
													   numberLines:1];
	//favoriteCountLabel.backgroundColor = [UIColor blueColor];
	[self addSubview:favoriteCountLabel];

	MIALabel *favoriteMiddleLabel = [[MIALabel alloc] initWithFrame:CGRectMake(self.frame.size.width - kFavoriteMiddleLabelMarginRight - kFavoriteMiddleLabelWidth,
																			   kFavoriteMiddleLabelMarginTop,
																			   kFavoriteMiddleLabelWidth,
																			   kFavoriteMiddleLabelHeight)
															   text:@"首收藏歌曲》"
															   font:UIFontFromSize(16.0f)
														  textColor:[UIColor whiteColor]
													  textAlignment:NSTextAlignmentRight
														numberLines:1];
	//favoriteMiddleLabel.backgroundColor = [UIColor greenColor];
	[self addSubview:favoriteMiddleLabel];

	MIALabel *cachedCountLabel = [[MIALabel alloc] initWithFrame:CGRectMake(self.frame.size.width - kCachedCountLabelMarginRight - kCachedCountLabelWidth,
																			kCachedCountLabelMarginTop,
																			kCachedCountLabelWidth,
																			kCachedCountLabelHeight)
															text:@"28首已下载到本地"
															font:UIFontFromSize(12.0f)
														  textColor:[UIColor whiteColor]
													  textAlignment:NSTextAlignmentLeft
														numberLines:1];
	//cachedCountLabel.backgroundColor = [UIColor greenColor];
	[self addSubview:cachedCountLabel];

	const static CGFloat kFavoriteIconMarginLeft	= 15;
	const static CGFloat kFavoriteIconMarginTop		= 15;
	const static CGFloat kFavoriteIconMarginWidth	= 16;

	const static CGFloat kFavoriteLabelMarginLeft	= kFavoriteIconMarginLeft + kFavoriteIconMarginWidth + 8;
	const static CGFloat kFavoriteLabelMarginTop	= 13;
	const static CGFloat kFavoriteLabelWidth		= 30;
	const static CGFloat kFavoriteLabelHeight		= 20;

	const static CGFloat kShareIconMarginLeft		= 15;
	const static CGFloat kShareIconMarginBottom		= 17;
	const static CGFloat kShareIconWidth			= 16;

	const static CGFloat kShareLabelMarginLeft		= kShareIconMarginLeft + kShareIconWidth + 8;
	const static CGFloat kShareLabelMarginBottom	= 14;
	const static CGFloat kShareLabelWidth			= 30;
	const static CGFloat kShareLabelHeight			= 20;


	// 两个子标题
	UIImageView *favoriteIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kFavoriteIconMarginLeft,
																					   kFavoriteIconMarginTop,
																					   kFavoriteIconMarginWidth,
																					   kFavoriteIconMarginWidth)];
	[favoriteIconImageView setImage:[UIImage imageNamed:@"favorite_white"]];
	[self addSubview:favoriteIconImageView];
	MIALabel *favoriteLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kFavoriteLabelMarginLeft,
																		 kFavoriteLabelMarginTop,
																		 kFavoriteLabelWidth,
																		 kFavoriteLabelHeight)
														 text:@"收藏"
														 font:UIFontFromSize(12.0f)
										   textColor:UIColorFromHex(@"a2a2a2", 1.0)
									   textAlignment:NSTextAlignmentLeft
												  numberLines:1];
	[self addSubview:favoriteLabel];

	UIImageView *shareIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kShareIconMarginLeft,
																					self.frame.size.height - kShareIconMarginBottom - kShareIconWidth,
																					kShareIconWidth,
																					kShareIconWidth)];
	[shareIconImageView setImage:[UIImage imageNamed:@"share"]];
	[self addSubview:shareIconImageView];
	MIALabel *shareLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kShareLabelMarginLeft,
																	  self.frame.size.height - kShareLabelMarginBottom - kShareLabelHeight,
																		 kShareLabelWidth,
																		 kShareLabelHeight)
														 text:@"分享"
														 font:UIFontFromSize(12.0f)
										   textColor:UIColorFromHex(@"a2a2a2", 1.0)
									   textAlignment:NSTextAlignmentLeft
												  numberLines:1];
	[self addSubview:shareLabel];

	static const CGFloat kWifiTipsLabelMarginBottom = 50;
	static const CGFloat kWifiTipsLabelHeight		= 20;

	MIALabel *wifiTipsLabel = [[MIALabel alloc] initWithFrame:CGRectMake(0,
																		 self.frame.size.height - kWifiTipsLabelMarginBottom - kWifiTipsLabelHeight,
																		 self.frame.size.width,
																		 kWifiTipsLabelHeight)
														 text:@"在非WIFI网络下，播放收藏歌曲不产生任何流量"
														 font:UIFontFromSize(12.0f)
										   textColor:[UIColor whiteColor]
									   textAlignment:NSTextAlignmentCenter
												  numberLines:1];
	[self addSubview:wifiTipsLabel];
}

#pragma mark - button Actions

- (void)playButtonAction:(id)sender {
	NSLog(@"play button clicked.");
}

- (void)coverMaskTouchAction:(id)sender {
	NSLog(@"cover Touch Action");
}

@end