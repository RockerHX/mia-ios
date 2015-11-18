//
//  HXMusicDetailShareCell.h
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "UITableView+FDTemplateLayoutCell.h"

@class ShareItem;
@class TTTAttributedLabel;
@class HXMusicDetailShareCell;

@protocol HXMusicDetailShareCellDelegate <NSObject>

@required
- (void)cellUserWouldLikeSeeSharerInfo:(nullable HXMusicDetailShareCell *)cell;

@end

@interface HXMusicDetailShareCell : UITableViewCell

@property (nonatomic, weak, nullable) IBOutlet                 id  <HXMusicDetailShareCellDelegate>delegate;

@property (nonatomic, weak, nullable) IBOutlet            UILabel *shareNickNameLabel;
@property (nonatomic, weak, nullable) IBOutlet TTTAttributedLabel *shareReasonLabel;

- (void)displayWithShareItem:(nullable ShareItem *)item;

@end
