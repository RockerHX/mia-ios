//
//  FavoriteCollectionViewCell.m
//  mia
//
//  Created by linyehui on 2015-09-20.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "FavoriteCollectionViewCell.h"
#import "MIALabel.h"
#import "UIImage+Extrude.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+BlurredImage.h"

@interface FavoriteCollectionViewCell()

@end

@implementation FavoriteCollectionViewCell {
	UIImageView *coverImageView;
	MIALabel *unreadCountLabel;
	MIALabel *unreadWordLabel;
	MIALabel *viewsLabel;
	MIALabel *musicNameLabel;
	MIALabel *artistLabel;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		//self.backgroundColor = [UIColor orangeColor];
		[self initUI:self.contentView];
		}

	return self;
}

- (void)initUI:(UIView *)contentView {
	//contentView.backgroundColor = [UIColor orangeColor];
	const static CGFloat kFavoriteCellMarginLeft			= 30;
	const static CGFloat kIndexLabelHeight					= 20;
	const static CGFloat kIndexLabelMarginTop				= 26;

	MIALabel *indexLabel = [[MIALabel alloc] initWithFrame:CGRectMake(0,
																  kIndexLabelMarginTop,
																  kFavoriteCellMarginLeft,
																  kIndexLabelHeight)
												  text:@"1"
												  font:UIFontFromSize(15.0f)
											 textColor:[UIColor blackColor]
										 textAlignment:NSTextAlignmentCenter
										   numberLines:1];
	//indexLabel.backgroundColor = [UIColor blueColor];
	[contentView addSubview:indexLabel];

	const static CGFloat kShareLabelMarginTop				= 0;
	const static CGFloat kShareLabelHeight					= 20;

	MIALabel *sharerLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kFavoriteCellMarginLeft,
																	  kShareLabelMarginTop,
																	  contentView.bounds.size.width - kFavoriteCellMarginLeft,
																	  kShareLabelHeight)
													  text:@"Jackie分享的"
													  font:UIFontFromSize(15.0f)
												 textColor:[UIColor grayColor]
											 textAlignment:NSTextAlignmentLeft
											   numberLines:1];
	//sharerLabel.backgroundColor = [UIColor yellowColor];
	[contentView addSubview:sharerLabel];

	const static CGFloat kDownloadStateMarginLeft		= kFavoriteCellMarginLeft;
	const static CGFloat kDownloadStateMarginTop		= kShareLabelMarginTop + kShareLabelHeight + 8;
	const static CGFloat kDownloadStateWidth			= 15;

	UIImageView *downloadStateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kDownloadStateMarginLeft,
																				kDownloadStateMarginTop,
																				kDownloadStateWidth,
																				kDownloadStateWidth)];
	[downloadStateImageView setImage:[UIImage imageNamed:@"favorite_downloading"]];
	[contentView addSubview:downloadStateImageView];

	const static CGFloat kSongLabelHeight					= 20;
	const static CGFloat kSongLabelMarginTop				= kShareLabelMarginTop + kShareLabelHeight + 5;
	const static CGFloat kSongLabelMarginLeft				= kDownloadStateMarginLeft + kDownloadStateWidth + 5;

	MIALabel *songLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kSongLabelMarginLeft,
																	  kSongLabelMarginTop,
																	  contentView.bounds.size.width - kSongLabelMarginLeft,
																	  kSongLabelHeight)
													  text:@"爱情的枪-左小诅咒"
													  font:UIFontFromSize(15.0f)
												 textColor:[UIColor blackColor]
											 textAlignment:NSTextAlignmentLeft
											   numberLines:1];
	//songLabel.backgroundColor = [UIColor greenColor];
	[contentView addSubview:songLabel];
}

- (void)setFavoriteItem:(FavoriteItem *)item {
	_favoriteItem = item;
/*
	[coverImageView sd_setImageWithURL:[NSURL URLWithString:shareItem.music.purl]
					  placeholderImage:[UIImage imageNamed:@"default_cover"]];
	UIImage *cutImage = [self getBannerImageFromCover:coverImageView.image containerSize:coverImageView.bounds.size];

	if (_isBiggerCell) {
		[coverImageView setImageToBlur:cutImage blurRadius:6.0 completionBlock:nil];
	}

	unreadCountLabel.text = [NSString stringWithFormat:@"%d", shareItem.newCommCnt];
	viewsLabel.text = [NSString stringWithFormat:@"%d", shareItem.cView];
	musicNameLabel.text = shareItem.music.name;
	artistLabel.text = shareItem.music.singerName;

	if (_shareItem.newCommCnt > 0 && _isMyProfile) {
		[unreadCountLabel setHidden:NO];
		[unreadWordLabel setHidden:NO];
		[musicNameLabel setHidden:YES];
		[artistLabel setHidden:YES];
	} else {
		[unreadCountLabel setHidden:YES];
		[unreadWordLabel setHidden:YES];
		[musicNameLabel setHidden:NO];
		[artistLabel setHidden:NO];
	}
*/
}

@end








