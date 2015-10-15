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

@implementation CommentCollectionViewCell {
	UIImageView		*_avatarImageView;
	MIALabel		*_titleLabel;
	MIALabel		*_commentLabel;
}

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
	_avatarImageView = [[UIImageView alloc] initWithFrame:imageFrame];
	_avatarImageView.layer.cornerRadius = LOGO_SIZE / 2;
	_avatarImageView.clipsToBounds = YES;
	_avatarImageView.layer.borderWidth = 1.0f;
	_avatarImageView.layer.borderColor = UIColorFromHex(@"a2a2a2", 1.0).CGColor;
	[_avatarImageView setUserInteractionEnabled:YES];
	[_avatarImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTouchAction:)]];
	[self.contentView addSubview:_avatarImageView];

	//title
	CGRect titleFrame = {.origin.x = kTitleMarginLeft,
		.origin.y = kTitleMarginTop,
		.size.width = self.bounds.size.width - kTitleMarginLeft,
		kCommentMarginTop - kTitleMarginTop};

	_titleLabel = [[MIALabel alloc] initWithFrame:titleFrame text:@"" font:UIBoldFontFromSize(12) textColor:UIColorFromHex(@"#000000", 1.0) textAlignment:NSTextAlignmentLeft numberLines:1];
	[self.contentView addSubview:_titleLabel];

	//comment
	CGRect commentFrame = {.origin.x = kCommentMarginLeft,
		.origin.y = kCommentMarginTop,
		.size.width = self.bounds.size.width - kCommentMarginLeft,
		self.bounds.size.height - kCommentMarginTop};

	_commentLabel = [[MIALabel alloc] initWithFrame:commentFrame text:@"" font:UIFontFromSize(12) textColor:UIColorFromHex(@"#949494", 1.0) textAlignment:NSTextAlignmentLeft numberLines:1];
	[self.contentView addSubview:_commentLabel];

	self.backgroundColor = [UIColor clearColor];
}

- (void)setDataItem:(CommentItem *)item {
	_dataItem = item;

	_titleLabel.text = item.unick;
	_commentLabel.text = item.cinfo;
	[_avatarImageView sd_setImageWithURL:[NSURL URLWithString:item.uimg]
					  placeholderImage:[UIImage imageNamed:@"default_cover"]];
}

#pragma mark - action

- (void)avatarTouchAction:(id)sender {
	if (_delegate) {
		[_delegate commentCellAvatarTouched:_dataItem];
	}
}

@end
