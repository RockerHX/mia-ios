//
//  HXMusicDetailSongCell.h
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTTAttributedLabel;
@class HXMusicDetailViewModel;

@interface HXMusicDetailSongCell : UITableViewCell

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *songInfoLabel;
@property (weak, nonatomic) IBOutlet           UIButton *starButton;

- (IBAction)starButtonPressed;

- (void)displayWithViewModel:(HXMusicDetailViewModel *)viewModel;

@end
