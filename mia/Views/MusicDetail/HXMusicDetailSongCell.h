//
//  HXMusicDetailSongCell.h
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "UITableView+FDTemplateLayoutCell.h"

@class ShareItem;
@class TTTAttributedLabel;

@interface HXMusicDetailSongCell : UITableViewCell

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *songInfoLabel;

- (void)displayWithPlayItem:(ShareItem *)item;

@end
