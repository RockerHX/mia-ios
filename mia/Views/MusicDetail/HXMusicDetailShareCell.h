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

@interface HXMusicDetailShareCell : UITableViewCell

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *shareInfoLabel;

- (void)displayWithShareItem:(ShareItem *)item;

@end
