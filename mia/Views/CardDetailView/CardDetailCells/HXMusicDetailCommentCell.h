//
//  HXMusicDetailCommentCell.h
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "UITableView+FDTemplateLayoutCell.h"
#import "HXComment.h"

@interface HXMusicDetailCommentCell : UITableViewCell

@property (nonatomic, weak, nullable) IBOutlet  UIView *containerView;
@property (nonatomic, weak, nullable) IBOutlet UILabel *contentLabel;

- (void)displayWithComment:(nullable HXComment *)comment;

@end
