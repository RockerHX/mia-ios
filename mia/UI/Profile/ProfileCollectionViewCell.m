//
//  ProfileCollectionViewCell.m
//  mia
//
//  Created by linyehui on 2015-09-20.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "ProfileCollectionViewCell.h"

@interface ProfileCollectionViewCell()

@end

@implementation ProfileCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor orangeColor];
		_topImage  = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 70, 70)];
		_topImage.backgroundColor = [UIColor redColor];
		[self.contentView addSubview:_topImage];

		_botlabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 80, 70, 30)];
		_botlabel.textAlignment = NSTextAlignmentCenter;
		_botlabel.textColor = [UIColor blueColor];
		_botlabel.font = [UIFont systemFontOfSize:15];
		_botlabel.backgroundColor = [UIColor purpleColor];
		[self.contentView addSubview:_botlabel];
		}

	return self;
}

@end








