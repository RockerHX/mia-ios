//
//  SearchResultCollectionViewCell.m
//  mia
//
//  Created by linyehui on 2015-09-20.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "SearchResultCollectionViewCell.h"
#import "MIALabel.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"
#import "SearchResultItem.h"

@interface SearchResultCollectionViewCell()

@end

@implementation SearchResultCollectionViewCell {
	UIImageView *_coverImageView;
	MIALabel 	*_titleLabel;
	MIALabel 	*_albumLabel;
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

	_coverImageView = [[UIImageView alloc] init];
	[_coverImageView setImage:[UIImage imageNamed:@"default_cover"]];
	[contentView addSubview:_coverImageView];

	_titleLabel = [[MIALabel alloc] initWithFrame:CGRectZero
											text:@"匆匆那年"
											font:UIFontFromSize(16.0f)
									   textColor:[UIColor blackColor]
								   textAlignment:NSTextAlignmentLeft
									 numberLines:1];
	[contentView addSubview:_titleLabel];

	_albumLabel = [[MIALabel alloc] initWithFrame:CGRectZero
											text:@"王菲 - 匆匆那年"
											font:UIFontFromSize(12.0f)
									   textColor:UIColorFromHex(@"a2a2a2", 1.0)
								   textAlignment:NSTextAlignmentLeft
									 numberLines:1];
	[contentView addSubview:_albumLabel];

	[_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(contentView.mas_centerY);
		make.size.mas_equalTo(CGSizeMake(70, 70));
		make.left.equalTo(contentView.mas_left).offset(15);
		make.bottom.equalTo(contentView.mas_bottom).offset(-15);
	}];
	[_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@20);
		make.bottom.equalTo(contentView.mas_centerY);
		make.left.equalTo(_coverImageView.mas_right).offset(15);
		make.right.equalTo(contentView.mas_right).offset(-15);
	}];
	[_albumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@20);
		make.top.equalTo(contentView.mas_centerY);
		make.left.equalTo(_coverImageView.mas_right).offset(15);
		make.right.equalTo(contentView.mas_right).offset(-15);
	}];

	UIView *lineView = [[UIView alloc] init];
	lineView.backgroundColor = UIColorFromHex(@"f2f2f2", 1.0);
	[contentView addSubview:lineView];
	[lineView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@1);
		make.bottom.equalTo(contentView.mas_bottom).offset(-1);
		make.left.equalTo(contentView.mas_left).offset(15);
		make.right.equalTo(contentView.mas_right);
	}];
}

- (void)setDataItem:(SearchResultItem *)item {
	_dataItem = item;

	[_coverImageView sd_setImageWithURL:[NSURL URLWithString:item.albumPic]
					  placeholderImage:[UIImage imageNamed:@"default_cover"]];

	[_titleLabel setText:item.title];
	[_albumLabel setText:[NSString stringWithFormat:@"%@ - %@", item.artist, item.albumName]];

}

@end








