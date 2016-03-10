//
//  HXMeDetailHeader.h
//  mia
//
//  Created by miaios on 16/1/28.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HXProfileHeaderModel.h"
#import "HXMessagePromptView.h"


typedef NS_ENUM(NSUInteger, HXMeDetailHeaderAction) {
    HXMeDetailHeaderActionSetting,
    HXMeDetailHeaderActionPlay,
    HXMeDetailHeaderActionShowFans,
    HXMeDetailHeaderActionShowFollow,
    HXMeDetailHeaderActionShowMessage,
};


@class HXMeDetailHeader;


@protocol HXMeDetailHeaderDelegate <NSObject>

@optional
- (void)detailHeader:(HXMeDetailHeader *)header takeAction:(HXMeDetailHeaderAction)action;

@end


@interface HXMeDetailHeader : UIView <HXMessagePromptViewDelegate>

@property (weak, nonatomic) IBOutlet       id  <HXMeDetailHeaderDelegate>delegate;
@property (weak, nonatomic) IBOutlet      UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet     UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet      UIView *playView;
@property (weak, nonatomic) IBOutlet     UILabel *playNickNameLabel;
@property (weak, nonatomic) IBOutlet     UILabel *fansCountLabel;
@property (weak, nonatomic) IBOutlet     UILabel *followCountLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarWidthConstraint;

@property (weak, nonatomic) IBOutlet HXMessagePromptView *messagePromptView;

- (IBAction)settingButtonPressed;
- (IBAction)playViewTaped;
- (IBAction)fansViewTaped;
- (IBAction)followViewTaped;

- (void)displayWithHeaderModel:(HXProfileHeaderModel *)model;

@end
