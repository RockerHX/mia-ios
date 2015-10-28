//
//  ProfileCollectionViewCell.m
//  mia
//
//  Created by linyehui on 2015-09-20.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "ProfileCollectionViewCell.h"
#import "MIALabel.h"
#import "UIImage+Extrude.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+BlurredImage.h"
#import "Masonry.h"

@interface ProfileCollectionViewCell()

@end

@implementation ProfileCollectionViewCell {
	UIImageView	*_coverImageView;
	MIALabel 	*_unreadCountLabel;
	MIALabel 	*_unreadWordLabel;
	MIALabel 	*_viewsLabel;
	MIALabel 	*_musicNameLabel;
	MIALabel 	*_artistLabel;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		//self.backgroundColor = [UIColor orangeColor];
		[self initUI:self.contentView];
		}

	return self;
}

- (void)initUI:(UIView *)contentView {
	_coverImageView = [[UIImageView alloc] initWithFrame:contentView.bounds];
	[_coverImageView setImage:[UIImage imageNamed:@"default_cover"]];
	[contentView addSubview:_coverImageView];

	UIImageView *coverMaskImageView = [[UIImageView alloc] initWithFrame:contentView.bounds];
	[coverMaskImageView setImage:[UIImage imageNamed:@"cover_mask"]];
	[contentView addSubview:coverMaskImageView];

	UIView *commentView = [[UIView alloc] init];
	commentView.backgroundColor = [UIColor redColor];
	[contentView addSubview:commentView];
	[self initCommentView:commentView];

	[commentView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(contentView.mas_centerX);
		make.centerY.equalTo(contentView.mas_centerY);
	}];

	static const CGFloat kViewsIconMarginMiddle 	= 2;
	static const CGFloat kViewsIconMarginBottom		= 12;
	static const CGFloat kViewsIconWidth			= 16;

	static const CGFloat kViewsLabelMarginMiddle	= 6;
	static const CGFloat kViewsLabelMarginBottom	= 12;
	static const CGFloat kViewsLabelHeight			= 16;

	UIImageView *viewsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(contentView.frame.size.width / 2 + kViewsIconMarginMiddle - kViewsIconWidth,
																				contentView.frame.size.height - kViewsIconMarginBottom - kViewsIconWidth,
																				kViewsIconWidth,
																				kViewsIconWidth)];
	[viewsImageView setImage:[UIImage imageNamed:@"MD-ViewCountIcon"]];
	[contentView addSubview:viewsImageView];

	_viewsLabel = [[MIALabel alloc] initWithFrame:CGRectMake(contentView.frame.size.width / 2 + kViewsIconMarginMiddle + kViewsLabelMarginMiddle,
															contentView.frame.size.height - kViewsLabelMarginBottom - kViewsLabelHeight,
															contentView.frame.size.width / 2 - kViewsIconMarginMiddle - kViewsLabelMarginMiddle,
															kViewsLabelHeight)
											text:@"12"
											font:UIFontFromSize(14.0f)
									   textColor:[UIColor whiteColor]
								   textAlignment:NSTextAlignmentLeft
									 numberLines:1];
	//viewsLabel.backgroundColor = [UIColor redColor];
	[contentView addSubview:_viewsLabel];

	static const CGFloat kMusicNameLabelMarginLeft		= 16;
	static const CGFloat kMusicNameLabelHeight			= 40;
	static const CGFloat kArtistLabelHeight				= 20;

	_musicNameLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kMusicNameLabelMarginLeft,
																contentView.frame.size.height / 2 - kMusicNameLabelHeight / 2,
																contentView.frame.size.width - 2 * kMusicNameLabelMarginLeft,
																kMusicNameLabelHeight)
												text:@"All Around The World"
												font:UIFontFromSize(17.0f)
												 textColor:[UIColor whiteColor]
											 textAlignment:NSTextAlignmentCenter
										 numberLines:2];
	//musicNameLabel.backgroundColor = [UIColor redColor];
	[contentView addSubview:_musicNameLabel];

	_artistLabel = [[MIALabel alloc] initWithFrame:CGRectMake(0,
															 contentView.frame.size.height / 2 + kMusicNameLabelHeight / 2,
															 contentView.frame.size.width,
															 kArtistLabelHeight)
											 text:@"Justin"
											 font:UIFontFromSize(14.0f)
										textColor:[UIColor whiteColor]
									textAlignment:NSTextAlignmentCenter
									  numberLines:1];
	//artistLabel.backgroundColor = [UIColor redColor];
	[contentView addSubview:_artistLabel];

}

- (void)initCommentView:(UIView *)contentView {
	_unreadCountLabel = [[MIALabel alloc] initWithFrame:CGRectZero
												   text:@"3"
												   font:UIFontFromSize(45.0f)
											  textColor:[UIColor whiteColor]
										  textAlignment:NSTextAlignmentCenter
											numberLines:1];
	_unreadCountLabel.backgroundColor = [UIColor blueColor];
	[contentView addSubview:_unreadCountLabel];

	_unreadWordLabel = [[MIALabel alloc] initWithFrame:CGRectZero
												  text:@"条新评论"
												  font:UIFontFromSize(14.0f)
											 textColor:[UIColor whiteColor]
										 textAlignment:NSTextAlignmentCenter
										   numberLines:1];
	_unreadWordLabel.backgroundColor = [UIColor greenColor];
	[contentView addSubview:_unreadWordLabel];

	[_unreadCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(contentView.mas_centerX);
		make.top.equalTo(contentView.mas_top);
		make.left.equalTo(contentView.mas_left).offset(15);
		make.right.equalTo(contentView.mas_right).offset(-15);
	}];
	[_unreadWordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(contentView.mas_centerX);
		make.top.equalTo(_unreadCountLabel.mas_bottom).offset(9);
		make.bottom.equalTo(contentView.mas_bottom);
		make.left.equalTo(contentView.mas_left).offset(15);
		make.right.equalTo(contentView.mas_right).offset(-15);
	}];
}

- (void)setShareItem:(ShareItem *)shareItem {
	_shareItem = shareItem;

	[_coverImageView sd_setImageWithURL:[NSURL URLWithString:shareItem.music.purl]
					  placeholderImage:[UIImage imageNamed:@"default_cover"]];
	UIImage *cutImage = [self getBannerImageFromCover:_coverImageView.image containerSize:_coverImageView.bounds.size];

	if (_isBiggerCell) {
		[_coverImageView setImageToBlur:cutImage blurRadius:6.0 completionBlock:nil];
	}

	_unreadCountLabel.text = [NSString stringWithFormat:@"%d", shareItem.newCommCnt];
	_viewsLabel.text = [NSString stringWithFormat:@"%d", shareItem.cView];
	_musicNameLabel.text = shareItem.music.name;
	_artistLabel.text = shareItem.music.singerName;

	if (_shareItem.newCommCnt > 0 && _isMyProfile) {
		[_unreadCountLabel setHidden:NO];
		[_unreadWordLabel setHidden:NO];
		[_musicNameLabel setHidden:YES];
		[_artistLabel setHidden:YES];
	} else {
		[_unreadCountLabel setHidden:YES];
		[_unreadWordLabel setHidden:YES];
		[_musicNameLabel setHidden:NO];
		[_artistLabel setHidden:NO];
	}
}

- (UIImage *)getBannerImageFromCover:(UIImage *)orgImage containerSize:(CGSize)containerSize {
	CGFloat cutHeight = containerSize.height * orgImage.size.width / containerSize.width;
	if (cutHeight <= 0.0) {
		cutHeight = orgImage.size.height / 3;
	}

	CGFloat cutY = orgImage.size.height / 2 - cutHeight / 2;
	if (cutY <= 0.0) {
		cutY = 0.0;
	}

	return [orgImage getSubImage:CGRectMake(0.0,
											cutY,
											orgImage.size.width,
											cutHeight)];
}

@end








