//
//  HXMusicDetailCoverCell.h
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HXMusicDetailCoverCellAction) {
    HXMusicDetailCoverCellActionPlay,
    HXMusicDetailCoverCellActionPause,
};

@class HXMusicDetailViewModel;
@class HXMusicDetailCoverCell;

@protocol HXMusicDetailCoverCellDelegate <NSObject>

@required
- (void)coverCell:(HXMusicDetailCoverCell *)cell takeAction:(HXMusicDetailCoverCellAction)action;

@end

@interface HXMusicDetailCoverCell : UITableViewCell

@property (weak, nonatomic) IBOutlet          id  <HXMusicDetailCoverCellDelegate>delegate;

@property (weak, nonatomic) IBOutlet      UIView *coverView;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet    UIButton *playButton;

- (IBAction)playButtonPressed;

- (void)displayWithViewModel:(HXMusicDetailViewModel *)viewModel;

@end
