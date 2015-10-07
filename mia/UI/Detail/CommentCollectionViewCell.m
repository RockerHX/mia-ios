//
//  CommentCollectionViewCell.m
//  mia
//
//  Created by linyehui on 2015-09-20.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "CommentCollectionViewCell.h"
#import "CommentItem.h"
#import "UIImageView+WebCache.h"

@interface CommentCollectionViewCell()

@end

@implementation CommentCollectionViewCell

static const CGFloat LOGO_X                                             = 15.0f;
static const CGFloat LOGO_Y                                             = 5.0f;
static const CGFloat LOGO_SIZE                                          = 35.0f;
static const CGFloat kTitleMarginTop									= 0;
static const CGFloat kTitleMarginLeft									= 65;
static const CGFloat kCommentMarginLeft									= 65;
static const CGFloat kCommentMarginTop									= 25;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		//self.backgroundColor = [UIColor orangeColor];
		[self initUI];
	}

	return self;
}

- (void)initUI {
	//Logo
	CGRect imageFrame = {.origin.x = LOGO_X, .origin.y = LOGO_Y, .size.width = LOGO_SIZE, .size.height = LOGO_SIZE};
	self.logoImageView = [[UIImageView alloc] initWithFrame:imageFrame];
	[self.contentView addSubview:self.logoImageView];

	//title
	CGRect titleFrame = {.origin.x = kTitleMarginLeft,
		.origin.y = kTitleMarginTop,
		.size.width = self.bounds.size.width - kTitleMarginLeft,
		kCommentMarginTop - kTitleMarginTop};

	self.titleLabel = [[MIALabel alloc] initWithFrame:titleFrame text:@"" font:UIBoldFontFromSize(12) textColor:UIColorFromHex(@"#000000", 1.0) textAlignment:NSTextAlignmentLeft numberLines:1];
	[self.contentView addSubview:self.titleLabel];

	//comment
	CGRect commentFrame = {.origin.x = kCommentMarginLeft,
		.origin.y = kCommentMarginTop,
		.size.width = self.bounds.size.width - kCommentMarginLeft,
		self.bounds.size.height - kCommentMarginTop};

	self.commentLabel = [[MIALabel alloc] initWithFrame:commentFrame text:@"" font:UIFontFromSize(12) textColor:UIColorFromHex(@"#949494", 1.0) textAlignment:NSTextAlignmentLeft numberLines:1];
	[self.contentView addSubview:self.commentLabel];

	self.backgroundColor = [UIColor clearColor];
}

- (void)updateWithCommentItem:(CommentItem *)item {
	_titleLabel.text = item.unick;
	_commentLabel.text = item.cinfo;
	[_logoImageView sd_setImageWithURL:[NSURL URLWithString:item.uimg]
					  placeholderImage:[UIImage imageNamed:@"default_cover"]];
}

@end








