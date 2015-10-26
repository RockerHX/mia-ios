//
//  HXMusicDetailInfectCell.h
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXInfectUserView;
@class TTTAttributedLabel;
@class HXMusicDetailViewModel;

@interface HXMusicDetailInfectCell : UITableViewCell

@property (weak, nonatomic) IBOutlet   HXInfectUserView *infectUserView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *infectPromptLabel;

- (void)displayWithViewModel:(HXMusicDetailViewModel *)viewModel;

@end
