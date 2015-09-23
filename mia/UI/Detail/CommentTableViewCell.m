//
//  CommentTableViewCell.m
//  mia
//
//  Created by linyehui on 2015-09-20.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "CommentItem.h"
#import "UIImageView+WebCache.h"

@interface CommentTableViewCell()

@property (retain,nonatomic) UIView *lineView;                                      //分割线

@end

@implementation CommentTableViewCell

static const CGFloat LOGO_X                                             = 15.0f;
static const CGFloat LOGO_Y                                             = 5.0f;
static const CGFloat LOGO_SIZE                                          = 35.0f;
static const CGFloat kTitleMarginTop									= 0;
static const CGFloat kTitleMarginLeft									= 65;
static const CGFloat kCommentMarginLeft									= 65;
static const CGFloat kCommentMarginTop									= 25;

//static const CGFloat TITLE_

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		//self.backgroundColor = [UIColor greenColor];
        //Logo
        CGRect imageFrame = {.origin.x = LOGO_X, .origin.y = LOGO_Y, .size.width = LOGO_SIZE, .size.height = LOGO_SIZE};
        self.logoImageView = [[UIImageView alloc] initWithFrame:imageFrame];
        [self.contentView addSubview:self.logoImageView];
        
        //title
        CGRect titleFrame = {.origin.x = kTitleMarginLeft,
                                .origin.y = kTitleMarginTop,
                                .size.width = self.bounds.size.width - kTitleMarginLeft,
                                kCommentMarginTop - kTitleMarginTop};
        
        self.titleLabel = [[MIALabel alloc] initWithFrame:titleFrame text:@"" font:UIBoldFontFromSize(15) textColor:UIColorFromHex(@"#000000", 1.0) textAlignment:NSTextAlignmentLeft numberLines:1];
        [self.contentView addSubview:self.titleLabel];

		//comment
		CGRect commentFrame = {.origin.x = kCommentMarginLeft,
			.origin.y = kCommentMarginTop,
			.size.width = self.bounds.size.width - kCommentMarginLeft,
			self.bounds.size.height - kCommentMarginTop};

		self.commentLabel = [[MIALabel alloc] initWithFrame:commentFrame text:@"" font:UIBoldFontFromSize(15) textColor:UIColorFromHex(@"#949494", 1.0) textAlignment:NSTextAlignmentLeft numberLines:1];
		[self.contentView addSubview:self.commentLabel];

        //分割线
        CGRect lineFrame = {.origin.x = 0.0f,
                            .origin.y = self.bounds.size.height - 0.5f,
                            .size.width = 200.0f,
                            .size.height = 0.5f};
        self.lineView = [[UIView alloc] initWithFrame:lineFrame];
        [self.lineView setBackgroundColor:UIColorFromHex(@"#D8D8D8", 1.0)];
        [self.contentView addSubview:self.lineView];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)updateWithCommentItem:(CommentItem *)item {
	_titleLabel.text = item.userName;
	_commentLabel.text = item.comment;
	[_logoImageView sd_setImageWithURL:[NSURL URLWithString:item.userAvatar]
					  placeholderImage:[UIImage imageNamed:@"default_cover"]];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end








