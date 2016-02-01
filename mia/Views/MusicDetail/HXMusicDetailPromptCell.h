//
//  HXMusicDetailPromptCell.h
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXMusicDetailViewModel;
@class HXInfectUserView;
@class HXMusicDetailPromptCell;

typedef NS_ENUM(NSUInteger, HXMusicDetailPromptCellAction) {
    HXMusicDetailPromptCellActionInfect,
    HXMusicDetailPromptCellActionShowInfecter
};

@protocol HXMusicDetailPromptCellDelegate <NSObject>

@optional
- (void)promptCell:(HXMusicDetailPromptCell *)cell takeAction:(HXMusicDetailPromptCellAction)action;

@end

@interface HXMusicDetailPromptCell : UITableViewCell

@property (weak, nonatomic) IBOutlet                id  <HXMusicDetailPromptCellDelegate>delegate;

@property (weak, nonatomic) IBOutlet           UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet           UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet           UIView *infectionView;
@property (weak, nonatomic) IBOutlet HXInfectUserView *infectUserView;
@property (weak, nonatomic) IBOutlet           UILabel *infectionCountLabel;
@property (weak, nonatomic) IBOutlet           UILabel *commentCountLabel;

- (IBAction)infectButtonPressed;

- (void)displayWithViewModel:(HXMusicDetailViewModel *)viewModel;

@end
