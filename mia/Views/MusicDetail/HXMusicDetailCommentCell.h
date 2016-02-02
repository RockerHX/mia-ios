//
//  HXMusicDetailCommentCell.h
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "UITableView+FDTemplateLayoutCell.h"
#import "HXComment.h"

@class HXMusicDetailCommentCell;

@protocol HXMusicDetailCommentCellDelegate <NSObject>

@optional
- (void)commentCellAvatarTaped:(HXMusicDetailCommentCell *)cell;

@end

@interface HXMusicDetailCommentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet          id  <HXMusicDetailCommentCellDelegate>delegate;

@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet     UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet     UILabel *contentLabel;

- (void)displayWithComment:(HXComment *)comment;

@end
