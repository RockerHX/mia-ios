//
//  HXRadioShareInfoView.h
//  mia
//
//  Created by miaios on 16/1/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HXRadioShareInfoAction) {
    HXRadioShareInfoActionAvatarTaped,
    HXRadioShareInfoActionSharerTaped,
    HXRadioShareInfoActionInfecterTaped,
    HXRadioShareInfoActionContentTaped
};

@class HXRadioShareInfoView;

@protocol HXRadioShareInfoViewDelegate <NSObject>

@optional
- (void)radioShareInfoView:(HXRadioShareInfoView *)infoView takeAction:(HXRadioShareInfoAction)action;

@end

@class ShareItem;
@class TTTAttributedLabel;

@interface HXRadioShareInfoView : UIView

@property (weak, nonatomic) IBOutlet                 id  <HXRadioShareInfoViewDelegate>delegate;

@property (weak, nonatomic) IBOutlet             UIView *sharerView;
@property (weak, nonatomic) IBOutlet        UIImageView *sharerAvatar;
@property (weak, nonatomic) IBOutlet        UIImageView *attentionIcon;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *sharerLabel;
@property (weak, nonatomic) IBOutlet            UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet            UILabel *shareContentLabel;
@property (weak, nonatomic) IBOutlet             UIView *commentView;
@property (weak, nonatomic) IBOutlet        UIImageView *commentAvatar;
@property (weak, nonatomic) IBOutlet            UILabel *commentLabel;

- (IBAction)sharerAvatarTaped;
- (IBAction)contentTaped;

- (void)displayWithItem:(ShareItem *)item;

@end