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

@interface SearchSuggestionCollectionViewCell()

@end

@implementation SearchSuggestionCollectionViewCell {
	MIALabel *titleLabel;
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
	titleLabel = [[MIALabel alloc] initWithFrame:CGRectZero
											   text:@"匆匆那年 - 王菲"
											   font:UIFontFromSize(16.0f)
									   textColor:[UIColor blackColor]
								   textAlignment:NSTextAlignmentLeft
									 numberLines:1];
	[contentView addSubview:titleLabel];

	[titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@20);
		make.centerY.equalTo(contentView.mas_centerY);
		make.left.equalTo(contentView.mas_left).offset(15);
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

- (void)setSuggestionItem:(SuggestionItem *)item {
	_suggestionItem = item;

	[titleLabel setText:[NSString stringWithFormat:@"%@ - %@", item.title, item.artist]];

}

@end








