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

@property (nonatomic, weak, nullable) IBOutlet      UIView *coverView;
@property (nonatomic, weak, nullable) IBOutlet UIImageView *coverImageView;
@property (nonatomic, weak, nullable) IBOutlet    UIButton *playButton;

- (IBAction)playButtonPressed;

- (void)displayWithViewModel:(nullable HXMusicDetailViewModel *)viewModel;
- (void)stopPlay;

@end
