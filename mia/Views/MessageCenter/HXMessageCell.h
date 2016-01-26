//
//  HXMessageCell.h
//  mia
//
//  Created by miaios on 16/1/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXMessageModel.h"

typedef NS_ENUM(NSUInteger, HXMessageCellAction) {
    HXMessageCellActionAvatarTaped
};

@class HXMessageCell;

@protocol HXMessageCellDelegate <NSObject>

@optional
- (void)messageCell:(HXMessageCell *)cell takeAction:(HXMessageCellAction)action;

@end

@interface HXMessageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet       id  <HXMessageCellDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (weak, nonatomic) IBOutlet   UIView *messageIcon;
@property (weak, nonatomic) IBOutlet  UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet  UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet  UILabel *timeLabel;

- (IBAction)avatarButtonPressed;

- (void)displayWithMessageModel:(HXMessageModel *)model;

@end