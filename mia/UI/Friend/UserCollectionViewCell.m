//
//  UserCollectionViewCell.m
//  mia
//
//  Created by linyehui on 2015-09-20.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "UserCollectionViewCell.h"
#import "MIALabel.h"
#import "MIAButton.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"
#import "UserItem.h"
#import "NSString+IsNull.h"
#import "MiaAPIHelper.h"
#import "HXAlertBanner.h"
#import "UserSession.h"

@interface UserCollectionViewCell()

@end

@implementation UserCollectionViewCell {
	UIImageView *_avatarImageView;
	MIALabel 	*_titleLabel;
	MIALabel 	*_detailLabel;
	MIAButton 	*_followButton;
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
	static const CGFloat avatarWidth = 46;

	_avatarImageView = [[UIImageView alloc] init];
	_avatarImageView.layer.cornerRadius = avatarWidth / 2;
	_avatarImageView.clipsToBounds = YES;
	_avatarImageView.layer.borderWidth = 0.5f;
	_avatarImageView.layer.borderColor = UIColorFromHex(@"808080", 1.0).CGColor;
	[_avatarImageView setImage:[UIImage imageNamed:@"HP-InfectUserDefaultHeader"]];
	[contentView addSubview:_avatarImageView];

	_followButton = [[MIAButton alloc] initWithFrame:CGRectZero
									   titleString:nil
										titleColor:nil
											  font:nil
										   logoImg:nil
								   backgroundImage:nil];
	[_followButton setBackgroundImage:[UIImage imageNamed:@"follow"] forState:UIControlStateNormal];
	[_followButton addTarget:self action:@selector(followButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[contentView addSubview:_followButton];


	_titleLabel = [[MIALabel alloc] initWithFrame:CGRectZero
											text:@"eden"
											font:UIFontFromSize(16.0f)
									   textColor:[UIColor blackColor]
								   textAlignment:NSTextAlignmentLeft
									 numberLines:1];
	[contentView addSubview:_titleLabel];

	_detailLabel = [[MIALabel alloc] initWithFrame:CGRectZero
											text:@"最近分享了 春分"
											font:UIFontFromSize(14.0f)
									   textColor:UIColorFromHex(@"808080", 1.0)
								   textAlignment:NSTextAlignmentLeft
									 numberLines:1];
	[contentView addSubview:_detailLabel];

	[_avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(contentView.mas_centerY);
		make.size.mas_equalTo(CGSizeMake(avatarWidth, avatarWidth));
		make.left.equalTo(contentView.mas_left).offset(5);
	}];
	[_followButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.size.mas_equalTo(CGSizeMake(35, 35));
		make.right.mas_equalTo(contentView.mas_right).offset(-15);
		make.centerY.mas_equalTo(contentView.mas_centerY).offset(-10);
	}];
	[_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.bottom.equalTo(contentView.mas_centerY);
		make.left.equalTo(_avatarImageView.mas_right).offset(15);
		make.right.equalTo(contentView.mas_right).offset(-10);
	}];
	[_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(contentView.mas_centerY).offset(6);
		make.left.equalTo(_avatarImageView.mas_right).offset(15);
		make.right.equalTo(contentView.mas_right).offset(-10);
	}];

	UIView *lineView = [[UIView alloc] init];
	lineView.backgroundColor = UIColorFromHex(@"f2f2f2", 1.0);
	[contentView addSubview:lineView];
	[lineView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@1);
		make.bottom.equalTo(contentView.mas_bottom);
		make.left.equalTo(_avatarImageView.mas_right).offset(15);
		make.right.equalTo(contentView.mas_right);
	}];
}

- (void)setDataItem:(UserItem *)item {
	_dataItem = item;

	[_avatarImageView sd_setImageWithURL:[NSURL URLWithString:item.userpic]
					   placeholderImage:[UIImage imageNamed:@"HP-InfectUserDefaultHeader"]];
	[_titleLabel setText:item.nick];
	[_detailLabel setText:[NSString stringWithFormat:@"最近分享了 %@", item.sharem]];

	if ([[UserSession standard].uid isEqualToString:_dataItem.uid]) {
		[_followButton setHidden:YES];
	} else {
		[self setIsFollowing:_dataItem.follow];
		[_followButton setHidden:NO];
	}
}

- (void)setIsFollowing:(BOOL)isFollow {
	_dataItem.follow = isFollow;
	if (isFollow) {
		[_followButton setBackgroundImage:[UIImage imageNamed:@"following"] forState:UIControlStateNormal];
	} else {
		[_followButton setBackgroundImage:[UIImage imageNamed:@"follow"] forState:UIControlStateNormal];
	}
}

#pragma mark - Actions

- (void)followButtonAction:(id)sender {
	BOOL isFollow = !_dataItem.follow;
	[self setIsFollowing:isFollow];

	// 如果回调出去，处理失败了还需要通知界面重新刷新，偷懒就在view里面做了操作了
	// linyehui 2016-01-28
	[MiaAPIHelper followWithUID:_dataItem.uid
					   isFollow:isFollow
				  completeBlock:
	 ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
		 if (!success) {
			 [self setIsFollowing:!isFollow];
			 [HXAlertBanner showWithMessage:(isFollow ? @"添加关注失败" : @"取消关注失败") tap:nil];
		 }
	} timeoutBlock:^(MiaRequestItem *requestItem) {
		[HXAlertBanner showWithMessage:@"请求超时，请重试！" tap:nil];
	}];
}

@end
