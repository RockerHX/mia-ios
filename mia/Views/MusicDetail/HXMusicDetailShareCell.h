//
//  HXMusicDetailShareCell.h
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "UITableView+FDTemplateLayoutCell.h"

@class TTTAttributedLabel;
@class HXMusicDetailViewModel;

@interface HXMusicDetailShareCell : UITableViewCell

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *shareInfoLabel;

- (void)displayWithViewModel:(HXMusicDetailViewModel *)viewModel;

@end
