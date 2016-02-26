//
//  SearchSuggestionCollectionViewCell.m
//  mia
//
//  Created by linyehui on 2015-09-20.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "SearchSuggestionCollectionViewCell.h"
#import "MIALabel.h"
#import "Masonry.h"
#import "SuggestionItem.h"
#import "UIConstants.h"

@interface SearchSuggestionCollectionViewCell()

@end

@implementation SearchSuggestionCollectionViewCell {
	MIALabel *_titleLabel;
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
	_titleLabel = [[MIALabel alloc] initWithFrame:CGRectZero
											   text:@"匆匆那年 - 王菲"
											   font:[UIFont systemFontOfSize:16.0f]
									   textColor:[UIColor blackColor]
								   textAlignment:NSTextAlignmentLeft
									 numberLines:1];
	[contentView addSubview:_titleLabel];

	[_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(contentView.mas_centerY);
		make.left.equalTo(contentView.mas_left).offset(15);
		make.right.equalTo(contentView.mas_right).offset(-15);
	}];

	UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = UIColorByHex(0xdcdcdc);
	[contentView addSubview:lineView];
	[lineView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@0.5);
		make.bottom.equalTo(contentView.mas_bottom).offset(-1);
		make.left.equalTo(contentView.mas_left).offset(15);
		make.right.equalTo(contentView.mas_right);
	}];
}

- (void)setDataItem:(SuggestionItem *)item {
	_dataItem = item;

	[_titleLabel setText:[NSString stringWithFormat:@"%@ - %@", item.title, item.artist]];

}

@end








