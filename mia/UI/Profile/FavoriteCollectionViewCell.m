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
#import "MIAButton.h"

@interface FavoriteCollectionViewCell()

@end

@implementation FavoriteCollectionViewCell {
	MIALabel *indexLabel;
	MIALabel *sharerLabel;
	UIImageView *downloadStateImageView;
	MIAButton *checkBoxButton;
	MIALabel *songLabel;
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

	indexLabel = [[MIALabel alloc] initWithFrame:CGRectMake(0,
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

	sharerLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kFavoriteCellMarginLeft,
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

	CGRect imageFrame = CGRectMake(kDownloadStateMarginLeft,
								   kDownloadStateMarginTop,
								   kDownloadStateWidth,
								   kDownloadStateWidth);
	downloadStateImageView = [[UIImageView alloc] initWithFrame:imageFrame];
	[downloadStateImageView setImage:[UIImage imageNamed:@"favorite_downloading"]];
	[contentView addSubview:downloadStateImageView];

	checkBoxButton = [[MIAButton alloc] initWithFrame:imageFrame
												   titleString:nil
													titleColor:nil
														  font:nil
													   logoImg:nil
											   backgroundImage:[UIImage imageNamed:@"uncheckbox"]];
	[checkBoxButton setBackgroundImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateSelected];
	[checkBoxButton addTarget:self action:@selector(selectCheckBoxAction:) forControlEvents:UIControlEventTouchUpInside];
	[checkBoxButton setHidden:YES];
	[contentView addSubview:checkBoxButton];

	const static CGFloat kSongLabelHeight					= 20;
	const static CGFloat kSongLabelMarginTop				= kShareLabelMarginTop + kShareLabelHeight + 5;
	const static CGFloat kSongLabelMarginLeft				= kDownloadStateMarginLeft + kDownloadStateWidth + 5;

	songLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kSongLabelMarginLeft,
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

	[indexLabel setText:[NSString stringWithFormat:@"%ld", _rowIndex + 1]];
	[sharerLabel setText:[NSString stringWithFormat:@"%@分享的", _favoriteItem.sNick]];
	[songLabel setText:[NSString stringWithFormat:@"%@-%@", _favoriteItem.music.name, _favoriteItem.music.singerName]];

	if (_isPlaying) {
		[sharerLabel setTextColor:UIColorFromHex(@"ff300e", 1.0)];
		[songLabel setTextColor:UIColorFromHex(@"ff300e", 1.0)];
	} else {
		[sharerLabel setTextColor:[UIColor grayColor]];
		[songLabel setTextColor:[UIColor blackColor]];
	}

	if (_isEditing) {
		[downloadStateImageView setHidden:YES];
		[checkBoxButton setHidden:NO];
	} else {
		[downloadStateImageView setHidden:NO];
		[checkBoxButton setHidden:YES];
	}
}

- (void)selectCheckBoxAction:(id)sender {
	[checkBoxButton setSelected:!checkBoxButton.isSelected];
	_favoriteItem.isSelected = checkBoxButton.isSelected;
}

@end








