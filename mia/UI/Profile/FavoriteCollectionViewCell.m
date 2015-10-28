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
#import "Masonry.h"

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
//	contentView.backgroundColor = [UIColor orangeColor];
	_indexLabel = [[MIALabel alloc] initWithFrame:CGRectZero
												  text:@"1"
												  font:UIFontFromSize(16.0f)
											 textColor:[UIColor blackColor]
										 textAlignment:NSTextAlignmentRight
										   numberLines:1];
//	_indexLabel.backgroundColor = [UIColor blueColor];
	[contentView addSubview:_indexLabel];

	_sharerLabel = [[MIALabel alloc] initWithFrame:CGRectZero
													  text:@"Jackie分享的"
													  font:UIFontFromSize(14.0f)
												 textColor:[UIColor grayColor]
											 textAlignment:NSTextAlignmentLeft
											   numberLines:1];
//	_sharerLabel.backgroundColor = [UIColor yellowColor];
	[contentView addSubview:_sharerLabel];

	_downloadStateImageView = [[UIImageView alloc] init];
	[_downloadStateImageView setImage:[UIImage imageNamed:@"favorite_downloading"]];
	[contentView addSubview:_downloadStateImageView];

	_checkBoxButton = [[MIAButton alloc] initWithFrame:CGRectZero
												   titleString:nil
													titleColor:nil
														  font:nil
													   logoImg:nil
											   backgroundImage:[UIImage imageNamed:@"uncheckbox"]];
	[_checkBoxButton setBackgroundImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateSelected];
//	[_checkBoxButton addTarget:self action:@selector(selectCheckBoxAction:) forControlEvents:UIControlEventTouchUpInside];
	[_checkBoxButton setHidden:YES];
	[contentView addSubview:_checkBoxButton];

	_songLabel = [[MIALabel alloc] initWithFrame:CGRectZero
													  text:@"爱情的枪-左小诅咒"
													  font:UIFontFromSize(15.0f)
												 textColor:[UIColor blackColor]
											 textAlignment:NSTextAlignmentLeft
											   numberLines:1];
//	_songLabel.backgroundColor = [UIColor greenColor];
	[contentView addSubview:_songLabel];


	[_indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.right.equalTo(_sharerLabel.mas_left).offset(-15);
		make.top.equalTo(contentView.mas_top).offset(25);
	}];

	[_sharerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(contentView.mas_left).offset(30);
		make.top.equalTo(contentView.mas_top).offset(5);
		make.right.equalTo(contentView.mas_right);
	}];

	[_downloadStateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(contentView.mas_left).offset(30);
		make.centerY.equalTo(_songLabel.mas_centerY);
		make.size.mas_equalTo(CGSizeMake(15, 15));
	}];

	[_songLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(contentView.mas_left).offset(50);
		make.right.equalTo(contentView.mas_right);
		make.top.equalTo(_sharerLabel.mas_bottom).offset(5);
	}];

	[_checkBoxButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(contentView.mas_left);
		make.top.equalTo(_sharerLabel.mas_bottom).offset(1);
		make.size.mas_equalTo(CGSizeMake(20, 20));
	}];
}

- (void)setDataItem:(FavoriteItem *)item {
	_dataItem = item;

	[_indexLabel setText:[NSString stringWithFormat:@"%ld", (long)(_rowIndex + 1)]];
	[_sharerLabel setText:[NSString stringWithFormat:@"%@分享的", _dataItem.sNick]];
	[_songLabel setText:[NSString stringWithFormat:@"%@-%@", _dataItem.music.name, _dataItem.music.singerName]];

	[self updateSelectedState];
	[self updatePlayingState];

	if (_isEditing) {
		[_downloadStateImageView setHidden:YES];
		[_indexLabel setHidden:YES];
		[_checkBoxButton setHidden:NO];

		[_songLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(_sharerLabel.mas_left);
			make.right.equalTo(self.mas_right);
			make.top.equalTo(_sharerLabel.mas_bottom).offset(5);
		}];
	} else {
		if (item.isCached) {
			[_downloadStateImageView setImage:[UIImage imageNamed:@"favorite_downloaded"]];
		} else {
			[_downloadStateImageView setImage:[UIImage imageNamed:@"favorite_downloading"]];
		}

		[_indexLabel setHidden:NO];
		[_downloadStateImageView setHidden:NO];
		[_checkBoxButton setHidden:YES];

		[_songLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.mas_left).offset(50);
			make.right.equalTo(self.mas_right);
			make.top.equalTo(_sharerLabel.mas_bottom).offset(5);
		}];
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

- (void)updateSelectedState {
	[_checkBoxButton setSelected:_dataItem.isSelected];
}

@end








