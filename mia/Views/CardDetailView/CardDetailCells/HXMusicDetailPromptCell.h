//
//  HXMusicDetailPromptCell.h
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXMusicDetailViewModel;

@interface HXMusicDetailPromptCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *viewCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;

- (void)displayWithViewModel:(HXMusicDetailViewModel *)viewModel;

@end
