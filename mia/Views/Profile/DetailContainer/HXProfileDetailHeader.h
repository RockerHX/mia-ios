//
//  HXProfileDetailHeader.h
//  mia
//
//  Created by miaios on 16/1/28.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(BOOL, HXProfileType) {
    HXProfileTypeHost = YES,
    HXProfileTypeGuest = NO
};

typedef NS_ENUM(NSUInteger, HXProfileDetailHeaderAction) {
    HXProfileDetailHeaderActionShowFans,
    HXProfileDetailHeaderActionShowFollow,
    HXProfileDetailHeaderActionShowMessage,
    HXProfileDetailHeaderActionTakeFollow,
};

@class HXProfileDetailHeader;

@protocol HXProfileDetailHeaderDelegate <NSObject>

@optional
- (void)detailHeader:(HXProfileDetailHeader *)header takeAction:(HXProfileDetailHeaderAction)action;

@end

@interface HXProfileDetailHeader : UIView

@property (weak, nonatomic) IBOutlet       id  <HXProfileDetailHeaderDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet     UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet     UILabel *fansCountLabel;
@property (weak, nonatomic) IBOutlet     UILabel *followCountLabel;
@property (weak, nonatomic) IBOutlet    UIButton *followButton;
@property (weak, nonatomic) IBOutlet      UIView *messagePromptView;
@property (weak, nonatomic) IBOutlet     UILabel *messageCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *messageAvatar;

@property (nonatomic, assign) HXProfileType  type;

- (IBAction)fansViewTaped;
- (IBAction)followViewTaped;
- (IBAction)messageViewTaped;
- (IBAction)followButtonPressed;

@end
