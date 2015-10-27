//
//  HXMusicDetailSongCell.h
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "UITableView+FDTemplateLayoutCell.h"

@class MusicItem;
@class TTTAttributedLabel;
@class HXMusicDetailSongCell;

@protocol HXMusicDetailSongCellDelegate <NSObject>

@required
- (void)cellUserWouldLikeStar:(HXMusicDetailSongCell *)cell;

@end

@interface HXMusicDetailSongCell : UITableViewCell

@property (weak, nonatomic) IBOutlet          id  <HXMusicDetailSongCellDelegate>delegate;

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *songInfoLabel;
@property (weak, nonatomic) IBOutlet           UIButton *starButton;

- (IBAction)starButtonPressed;

- (void)displayWithMusicItem:(MusicItem *)item;
- (void)updateStatStateWithFavorite:(BOOL)favorite;

@end
