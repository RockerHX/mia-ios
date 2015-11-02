//
//  HXMusicDetailCoverCell.h
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXMusicDetailViewModel;

@protocol HXMusicDetailCoverCellDelegate <NSObject>

@required

@end

@interface HXMusicDetailCoverCell : UITableViewCell

@property (weak, nonatomic) IBOutlet          id  <HXMusicDetailCoverCellDelegate>delegate;

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet    UIButton *playButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverToTopConstraint;

- (IBAction)playButtonPressed;

- (void)displayWithViewModel:(HXMusicDetailViewModel *)viewModel;
- (void)stopPlay;

@end
