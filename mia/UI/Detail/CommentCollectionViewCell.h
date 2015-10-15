//
//  CommentCollectionViewCell.h
//  mia
//
//  Created by linyehui on 2015-09-20.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MIALabel.h"

@class CommentItem;

@protocol CommentCellDelegate

- (void)commentCellAvatarTouched:(CommentItem *)item;

@end

@interface CommentCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic)id<CommentCellDelegate> delegate;
@property (strong, nonatomic)CommentItem *dataItem;

@end
