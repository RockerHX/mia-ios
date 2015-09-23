//
//  ProfileCollectionViewCell.m
//  mia
//
//  Created by linyehui on 2015-09-20.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "ProfileCollectionViewCell.h"
#import "MIALabel.h"

@interface ProfileCollectionViewCell()

@end

@implementation ProfileCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor orangeColor];
//		_topImage  = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 70, 70)];
//		_topImage.backgroundColor = [UIColor redColor];
//		[self.contentView addSubview:_topImage];
//
//		_botlabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 80, 70, 30)];
//		_botlabel.textAlignment = NSTextAlignmentCenter;
//		_botlabel.textColor = [UIColor blueColor];
//		_botlabel.font = [UIFont systemFontOfSize:15];
//		_botlabel.backgroundColor = [UIColor purpleColor];
//		[self.contentView addSubview:_botlabel];
		[self initUI:self.contentView];
		}

	return self;
}

- (void)initUI:(UIView *)contentView {
	UIImageView *coverImageView = [[UIImageView alloc] initWithFrame:contentView.bounds];
	[coverImageView setImage:[UIImage imageNamed:@"default_cover"]];
	[contentView addSubview:coverImageView];
	UIImageView *coverMaskImageView = [[UIImageView alloc] initWithFrame:contentView.bounds];
	[coverMaskImageView setImage:[UIImage imageNamed:@"cover_mask"]];
	[contentView addSubview:coverMaskImageView];


	const static CGFloat kUnreadCountLabelHeight			= 40;
	const static CGFloat kUnreadWordLabelMarginTop			= 9;
	const static CGFloat kUnreadWordLabelHeight				= 20;

	MIALabel *unreadCountLabel = [[MIALabel alloc] initWithFrame:CGRectMake(0,
																			contentView.frame.size.height / 2 - kUnreadCountLabelHeight,
																			  contentView.frame.size.width,
																			  kUnreadCountLabelHeight)
															  text:@"3"
															  font:UIFontFromSize(35.0f)
														 textColor:[UIColor whiteColor]
													 textAlignment:NSTextAlignmentCenter
													   numberLines:1];
	//unreadCountLabel.backgroundColor = [UIColor blueColor];
	[contentView addSubview:unreadCountLabel];

	MIALabel *unreadWordLabel = [[MIALabel alloc] initWithFrame:CGRectMake(0,
																		   contentView.frame.size.height / 2 + kUnreadWordLabelMarginTop,
																			  contentView.frame.size.width,
																			  kUnreadWordLabelHeight)
															   text:@"条新评论"
															   font:UIFontFromSize(16.0f)
														  textColor:[UIColor whiteColor]
													  textAlignment:NSTextAlignmentCenter
														numberLines:1];
	//unreadWordLabel.backgroundColor = [UIColor greenColor];
	[contentView addSubview:unreadWordLabel];

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
	[viewsImageView setImage:[UIImage imageNamed:@"views"]];
	[contentView addSubview:viewsImageView];

	MIALabel *viewsLabel = [[MIALabel alloc] initWithFrame:CGRectMake(contentView.frame.size.width / 2 + kViewsIconMarginMiddle + kViewsLabelMarginMiddle,
															contentView.frame.size.height - kViewsLabelMarginBottom - kViewsLabelHeight,
															contentView.frame.size.width / 2 - kViewsIconMarginMiddle - kViewsLabelMarginMiddle,
															kViewsLabelHeight)
											text:@"12"
											font:UIFontFromSize(12.0f)
									   textColor:[UIColor whiteColor]
								   textAlignment:NSTextAlignmentLeft
									 numberLines:1];
	//viewsLabel.backgroundColor = [UIColor redColor];
	[contentView addSubview:viewsLabel];

	static const CGFloat kMusicNameLabelMarginLeft		= 16;
	static const CGFloat kMusicNameLabelHeight			= 40;
	static const CGFloat kArtistLabelHeight				= 20;

	MIALabel *musicNameLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kMusicNameLabelMarginLeft,
																	  contentView.frame.size.height / 2 - kMusicNameLabelHeight / 2,
																	  contentView.frame.size.width - 2 * kMusicNameLabelMarginLeft,
																	  kMusicNameLabelHeight)
													  text:@"All Around The World"
													  font:UIFontFromSize(14.0f)
												 textColor:[UIColor whiteColor]
											 textAlignment:NSTextAlignmentCenter
											   numberLines:2];
	//musicNameLabel.backgroundColor = [UIColor redColor];
	[contentView addSubview:musicNameLabel];

	MIALabel *artistLabel = [[MIALabel alloc] initWithFrame:CGRectMake(0,
																		  contentView.frame.size.height / 2 + kMusicNameLabelHeight / 2,
																		  contentView.frame.size.width,
																		  kArtistLabelHeight)
														  text:@"Justin"
														  font:UIFontFromSize(12.0f)
													 textColor:[UIColor whiteColor]
												 textAlignment:NSTextAlignmentCenter
												   numberLines:1];
	//artistLabel.backgroundColor = [UIColor redColor];
	[contentView addSubview:artistLabel];

}

@end








