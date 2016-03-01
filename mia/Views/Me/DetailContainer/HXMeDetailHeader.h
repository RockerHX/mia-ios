//
//  HXMeDetailHeader.h
//  mia
//
//  Created by miaios on 16/1/28.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HXProfileHeaderModel.h"

typedef NS_ENUM(BOOL, HXProfileType) {
    HXProfileTypeHost = YES,
    HXProfileTypeGuest = NO
};

typedef NS_ENUM(NSUInteger, HXMeDetailHeaderAction) {
    HXMeDetailHeaderActionSetting,
    HXMeDetailHeaderActionAttention,
    HXMeDetailHeaderActionPlayFM,
    HXMeDetailHeaderActionShowFans,
    HXMeDetailHeaderActionShowFollow
};

@class HXMeDetailHeader;

@protocol HXMeDetailHeaderDelegate <NSObject>

@optional
- (void)detailHeader:(HXMeDetailHeader *)header takeAction:(HXMeDetailHeaderAction)action;

@end

@interface HXMeDetailHeader : UIView

@property (weak, nonatomic) IBOutlet       id  <HXMeDetailHeaderDelegate>delegate;
@property (weak, nonatomic) IBOutlet      UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet     UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet     UILabel *fansCountLabel;
@property (weak, nonatomic) IBOutlet     UILabel *followCountLabel;
@property (weak, nonatomic) IBOutlet    UIButton *actionButton;

@property (nonatomic, assign) HXProfileType  type;

- (IBAction)actionButtonPressed;
- (IBAction)playFMTaped;
- (IBAction)fansViewTaped;
- (IBAction)followViewTaped;

- (void)displayWithHeaderModel:(HXProfileHeaderModel *)model;

@end
