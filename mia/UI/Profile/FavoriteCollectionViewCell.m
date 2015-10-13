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
	MIALabel 		*_indexLabel;
	MIALabel 		*_sharerLabel;
	UIImageView 	*_downloadStateImageView;
	MIAButton 		*_checkBoxButton;
	MIALabel 		*_songLabel;
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

	_indexLabel = [[MIALabel alloc] initWithFrame:CGRectMake(0,
																  kIndexLabelMarginTop,
																  kFavoriteCellMarginLeft,
																  kIndexLabelHeight)
												  text:@"1"
												  font:UIFontFromSize(15.0f)
											 textColor:[UIColor blackColor]
										 textAlignment:NSTextAlignmentCenter
										   numberLines:1];
	//indexLabel.backgroundColor = [UIColor blueColor];
	[contentView addSubview:_indexLabel];

	const static CGFloat kShareLabelMarginTop				= 0;
	const static CGFloat kShareLabelHeight					= 20;

	_sharerLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kFavoriteCellMarginLeft,
																	  kShareLabelMarginTop,
																	  contentView.bounds.size.width - kFavoriteCellMarginLeft,
																	  kShareLabelHeight)
													  text:@"Jackie分享的"
													  font:UIFontFromSize(15.0f)
												 textColor:[UIColor grayColor]
											 textAlignment:NSTextAlignmentLeft
											   numberLines:1];
	//sharerLabel.backgroundColor = [UIColor yellowColor];
	[contentView addSubview:_sharerLabel];

	const static CGFloat kDownloadStateMarginLeft		= kFavoriteCellMarginLeft;
	const static CGFloat kDownloadStateMarginTop		= kShareLabelMarginTop + kShareLabelHeight + 8;
	const static CGFloat kDownloadStateWidth			= 15;

	CGRect imageFrame = CGRectMake(kDownloadStateMarginLeft,
								   kDownloadStateMarginTop,
								   kDownloadStateWidth,
								   kDownloadStateWidth);
	_downloadStateImageView = [[UIImageView alloc] initWithFrame:imageFrame];
	[_downloadStateImageView setImage:[UIImage imageNamed:@"favorite_downloading"]];
	[contentView addSubview:_downloadStateImageView];

	_checkBoxButton = [[MIAButton alloc] initWithFrame:imageFrame
												   titleString:nil
													titleColor:nil
														  font:nil
													   logoImg:nil
											   backgroundImage:[UIImage imageNamed:@"uncheckbox"]];
	[_checkBoxButton setBackgroundImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateSelected];
	[_checkBoxButton addTarget:self action:@selector(selectCheckBoxAction:) forControlEvents:UIControlEventTouchUpInside];
	[_checkBoxButton setHidden:YES];
	[contentView addSubview:_checkBoxButton];

	const static CGFloat kSongLabelHeight					= 20;
	const static CGFloat kSongLabelMarginTop				= kShareLabelMarginTop + kShareLabelHeight + 5;
	const static CGFloat kSongLabelMarginLeft				= kDownloadStateMarginLeft + kDownloadStateWidth + 5;

	_songLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kSongLabelMarginLeft,
																	  kSongLabelMarginTop,
																	  contentView.bounds.size.width - kSongLabelMarginLeft,
																	  kSongLabelHeight)
													  text:@"爱情的枪-左小诅咒"
													  font:UIFontFromSize(15.0f)
												 textColor:[UIColor blackColor]
											 textAlignment:NSTextAlignmentLeft
											   numberLines:1];
	//songLabel.backgroundColor = [UIColor greenColor];
	[contentView addSubview:_songLabel];
}

- (void)setDataItem:(FavoriteItem *)item {
	_dataItem = item;

	[_indexLabel setText:[NSString stringWithFormat:@"%ld", (long)(_rowIndex + 1)]];
	[_sharerLabel setText:[NSString stringWithFormat:@"%@分享的", _dataItem.sNick]];
	[_songLabel setText:[NSString stringWithFormat:@"%@-%@", _dataItem.music.name, _dataItem.music.singerName]];
	[_checkBoxButton setSelected:_dataItem.isSelected];

	[self updatePlayingState];

	if (_isEditing) {
		[_downloadStateImageView setHidden:YES];
		[_checkBoxButton setHidden:NO];
	} else {
		if (item.isCached) {
			[_downloadStateImageView setImage:[UIImage imageNamed:@"favorite_downloaded"]];
		} else {
			[_downloadStateImageView setImage:[UIImage imageNamed:@"favorite_downloading"]];
		}

		[_downloadStateImageView setHidden:NO];
		[_checkBoxButton setHidden:YES];
	}
}

- (void)selectCheckBoxAction:(id)sender {
	[_checkBoxButton setSelected:!_checkBoxButton.isSelected];
	_dataItem.isSelected = _checkBoxButton.isSelected;
}

- (void)updatePlayingState {
	if (_dataItem.isPlaying) {
		[_sharerLabel setTextColor:UIColorFromHex(@"ff300e", 1.0)];
		[_songLabel setTextColor:UIColorFromHex(@"ff300e", 1.0)];
	} else {
		[_sharerLabel setTextColor:[UIColor grayColor]];
		[_songLabel setTextColor:[UIColor blackColor]];
	}
}

@end








