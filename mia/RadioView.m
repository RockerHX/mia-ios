//
//  RadioView.m
//  mia
//
//  Created by linyehui on 2015/09/09.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "RadioView.h"

#import "UIImage+ColorToImage.h"
#import "HJWButton.h"

@implementation RadioView {
	HJWButton *logoButton;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self){
//		self.userInteractionEnabled = YES;
//		self.backgroundColor = [UIColor redColor];
		[self loadButtons];
	}

	return self;
}

- (void)loadButtons {
	CGRect logoButtonFrame = CGRectMake(50,
										10.0f,
										200,
										50);

	logoButton = [[HJWButton alloc] initWithFrame:logoButtonFrame
									  titleString:@"Ping" titleColor:[UIColor whiteColor]
											 font:UIFontFromSize(15)
										  logoImg:nil
								  backgroundImage:[UIImage createImageWithColor:DADU_DEFAULT_COLOR]];

	logoButton.layer.masksToBounds = YES;
	logoButton.layer.cornerRadius = 5.0f;
//	logoButton.clipsToBounds = YES;
//	logoButton.userInteractionEnabled = YES;
	//	logoButton.layer.borderWidth = 3.0f;
	//	logoButton.layer.borderColor = [UIColorFromHex(@"#EFEFEF", 1.0) CGColor];
	[logoButton addTarget:self action:@selector(onClickPingButton:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:logoButton];
}

#pragma mark - Actions

- (void)onClickPingButton:(id)sender {
	NSLog(@"OnClick Ping");
}

@end
