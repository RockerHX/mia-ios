//
//  MIATipView.m
//  mia
//
//  Created by linyehui on 14-8-15.
//  Copyright (c) 2014年 Mia Music. All rights reserved.
//

#import "MIATipView.h"
#import "MIALabel.h"
#import "MIAButton.h"
#import "UIImage+ColorToImage.h"

@interface MIATipView()

@property (retain, nonatomic) MIALabel *label;
@property (retain, nonatomic) MIAButton *button;

@end

@implementation MIATipView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/**
 *  初始化TipView
 *
 *  @param frame   大小
 *  @param content 文案
 *
 */
-(id)initWithFrame:(CGRect)frame content:(NSString *)content{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor clearColor];
        self.label = [[MIALabel alloc] initWithFrame:frame text:content font:UIFontFromSize(12) textColor:UIColorFromHex(@"747C8D", 1.0) textAlignment:NSTextAlignmentCenter numberLines:0];
        [self addSubview:self.label];
    }
    return self;
}

- (id)initMyGambleTipWithFrame:(CGRect)frame content:(NSString *)content buttonTitle:(NSString *)buttonTitle{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor clearColor];
        self.label = [[MIALabel alloc] initWithFrame:frame text:content font:UIFontFromSize(12) textColor:UIColorFromHex(@"747C8D", 1.0) textAlignment:NSTextAlignmentCenter numberLines:0];
        [self.label sizeToFit];
        self.label.frame = CGRectMake(self.frame.size.width/2 - self.label.frame.size.width/2, self.frame.size.height/2 - self.label.frame.size.height/2 - 30.0f, self.label.frame.size.width, self.label.frame.size.height);
        [self addSubview:self.label];
        self.button = [[MIAButton alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 130.0f/2, self.label.frame.origin.y + self.label.frame.size.height + 30.0f, 130.0f, 35.0f) titleString:buttonTitle titleColor:[UIColor whiteColor] font:UIFontFromSize(15) logoImg:nil backgroundImage:[UIImage createImageWithColor:DADU_DEFAULT_COLOR]];
        self.button.layer.masksToBounds = YES;
        self.button.layer.cornerRadius = 5.0f;
        [self.button addTarget:self action:@selector(onClickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];
    }
    return self;
}

/**
 *  更新TipView的提示文案
 *
 *  @param content 新文案
 */
-(void)updateContent:(NSString *)content{
    self.label.text = content;
    [self.label sizeToFit];
    CGRect labelFrame = CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, self.frame.size.height);
    self.label.frame = labelFrame;
}

- (void)onClickButtonAction:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_GAMBLE" object:nil userInfo:nil];
}

@end







