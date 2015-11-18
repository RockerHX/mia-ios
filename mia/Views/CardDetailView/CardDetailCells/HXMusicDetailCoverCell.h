//
//  HXMusicDetailCoverCell.h
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXMusicDetailViewModel;

@interface HXMusicDetailCoverCell : UITableViewCell

@property (weak, nonatomic) IBOutlet      UIView *coverView;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet    UIButton *playButton;

- (IBAction)playButtonPressed;

- (void)displayWithViewModel:(HXMusicDetailViewModel *)viewModel;
- (void)stopPlay;

@end
