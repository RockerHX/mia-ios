//
//  SearchResultCollectionViewCell.m
//  mia
//
//  Created by linyehui on 2015-09-20.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "SearchResultCollectionViewCell.h"
#import "MIALabel.h"
#import "MIAButton.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"
#import "SearchResultItem.h"

@interface SearchResultCollectionViewCell()

@end

@implementation SearchResultCollectionViewCell {
	UIImageView *_coverImageView;
	MIALabel 	*_titleLabel;
	MIALabel 	*_albumLabel;
	MIAButton 	*_playButton;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self initUI:self.contentView];
	}

	return self;
}

- (void)initUI:(UIView *)contentView {
//	contentView.backgroundColor = arc4random() %2 == 0 ? [UIColor redColor] : [UIColor greenColor];
	_coverImageView = [[UIImageView alloc] init];
	[_coverImageView setImage:[UIImage imageNamed:@"default_cover"]];
	[contentView addSubview:_coverImageView];
	_coverImageView.layer.borderWidth = 0.5f;
	_coverImageView.layer.borderColor = UIColorFromHex(@"dcdcdc", 1.0).CGColor;


	_playButton = [[MIAButton alloc] initWithFrame:CGRectZero
									   titleString:nil
										titleColor:nil
											  font:nil
										   logoImg:nil
								   backgroundImage:nil];
	[_playButton setBackgroundImage:[UIImage imageNamed:@"M-PlayIcon"] forState:UIControlStateNormal];
	[_playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[contentView addSubview:_playButton];


	_titleLabel = [[MIALabel alloc] initWithFrame:CGRectZero
											text:@"匆匆那年"
											font:UIFontFromSize(16.0f)
									   textColor:[UIColor blackColor]
								   textAlignment:NSTextAlignmentLeft
									 numberLines:1];
	[contentView addSubview:_titleLabel];

	_albumLabel = [[MIALabel alloc] initWithFrame:CGRectZero
											text:@"王菲 - 匆匆那年"
											font:UIFontFromSize(14.0f)
									   textColor:UIColorFromHex(@"808080", 1.0)
								   textAlignment:NSTextAlignmentLeft
									 numberLines:1];
	[contentView addSubview:_albumLabel];

	[_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(contentView.mas_centerY);
		make.size.mas_equalTo(CGSizeMake(75, 75));
		make.left.equalTo(contentView.mas_left).offset(5);
	}];
	[_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.size.mas_equalTo(CGSizeMake(30, 30));
		make.centerX.mas_equalTo(_coverImageView.mas_centerX);
		make.centerY.mas_equalTo(_coverImageView.mas_centerY);
	}];
	[_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.bottom.equalTo(contentView.mas_centerY);
		make.left.equalTo(_coverImageView.mas_right).offset(15);
		make.right.equalTo(contentView.mas_right).offset(-10);
	}];
	[_albumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(contentView.mas_centerY).offset(6);
		make.left.equalTo(_coverImageView.mas_right).offset(15);
		make.right.equalTo(contentView.mas_right).offset(-10);
	}];

	UIView *lineView = [[UIView alloc] init];
	lineView.backgroundColor = UIColorFromHex(@"f2f2f2", 1.0);
	[contentView addSubview:lineView];
	[lineView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@1);
		make.bottom.equalTo(contentView.mas_bottom);
		make.left.equalTo(contentView.mas_left).offset(5);
		make.right.equalTo(contentView.mas_right);
	}];
}

- (void)setDataItem:(SearchResultItem *)item {
	_dataItem = item;

	[_coverImageView sd_setImageWithURL:[NSURL URLWithString:item.albumPic]
					  placeholderImage:[UIImage imageNamed:@"default_cover"]];

	[_titleLabel setText:item.title];
	[_albumLabel setText:[NSString stringWithFormat:@"%@ - %@", item.artist, item.albumName]];

	[self setIsPlaying:_dataItem.isPlaying];
}

- (void)setIsPlaying:(BOOL)isPlaying {
	_dataItem.isPlaying = isPlaying;
	if (isPlaying) {
		[_playButton setBackgroundImage:[UIImage imageNamed:@"M-PauseIcon"] forState:UIControlStateNormal];
	} else {
		[_playButton setBackgroundImage:[UIImage imageNamed:@"M-PlayIcon"] forState:UIControlStateNormal];
	}
}

#pragma mark - Actions

- (void)playButtonAction:(id)sender {
	[_cellDelegate searchResultCellClickedPlayButtonAtIndexPath:_indexPath];
}

@end
