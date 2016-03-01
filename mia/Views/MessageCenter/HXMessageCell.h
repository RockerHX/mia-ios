//
//  HXMessageCell.h
//  mia
//
//  Created by miaios on 16/1/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageItem.h"

@class TTTAttributedLabel;

@interface HXMessageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet        UIImageView *avatar;
@property (weak, nonatomic) IBOutlet             UIView *messageIcon;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet            UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet            UILabel *timeLabel;

- (void)displayWithMessageItem:(MessageItem *)item;

@end
