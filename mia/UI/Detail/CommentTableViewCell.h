//
//  CommentTableViewCell.h
//  mia
//
//  Created by linyehui on 2015-09-20.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MIALabel.h"

@class CommentItem;

@interface CommentTableViewCell : UITableViewCell

@property (retain, nonatomic) UIImageView *logoImageView;
@property (retain, nonatomic) MIALabel *titleLabel;
@property (retain, nonatomic) MIALabel *commentLabel;

- (void)updateWithCommentItem:(CommentItem *)item;

@end
