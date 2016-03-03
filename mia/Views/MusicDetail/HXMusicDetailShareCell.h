//
//  HXMusicDetailShareCell.h
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "UITableView+FDTemplateLayoutCell.h"

typedef NS_ENUM(NSUInteger, HXMusicDetailShareCellAction) {
    HXMusicDetailShareCellActionShowSharer,
};

@class ShareItem;
@class TTTAttributedLabel;
@class HXMusicDetailShareCell;

@protocol HXMusicDetailShareCellDelegate <NSObject>

@required
- (void)shareCell:(HXMusicDetailShareCell *)cell takeAction:(HXMusicDetailShareCellAction)action;

@end

@interface HXMusicDetailShareCell : UITableViewCell

@property (weak, nonatomic) IBOutlet                 id  <HXMusicDetailShareCellDelegate>delegate;

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *shareInfoLabel;

- (void)displayWithShareItem:(ShareItem *)item;

@end
