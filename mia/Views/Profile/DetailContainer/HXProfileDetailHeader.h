//
//  HXProfileDetailHeader.h
//  mia
//
//  Created by miaios on 16/1/28.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HXProfileHeaderModel.h"

typedef NS_ENUM(NSUInteger, HXProfileDetailHeaderAction) {
    HXProfileDetailHeaderActionAttention,
    HXProfileDetailHeaderActionPlay,
    HXProfileDetailHeaderActionShowFans,
    HXProfileDetailHeaderActionShowFollow,
};

@class HXProfileDetailHeader;

@protocol HXProfileDetailHeaderDelegate <NSObject>

@optional
- (void)detailHeader:(HXProfileDetailHeader *)header takeAction:(HXProfileDetailHeaderAction)action;

@end

@interface HXProfileDetailHeader : UIView

@property (weak, nonatomic) IBOutlet       id  <HXProfileDetailHeaderDelegate>delegate;
@property (weak, nonatomic) IBOutlet      UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet     UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet     UILabel *fansCountLabel;
@property (weak, nonatomic) IBOutlet     UILabel *followCountLabel;
@property (weak, nonatomic) IBOutlet    UIButton *actionButton;

- (IBAction)actionButtonPressed;
- (IBAction)playViewTaped;
- (IBAction)fansViewTaped;
- (IBAction)followViewTaped;

- (void)displayWithHeaderModel:(HXProfileHeaderModel *)model;

@end
