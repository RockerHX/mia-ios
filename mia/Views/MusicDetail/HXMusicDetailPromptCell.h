//
//  HXMusicDetailPromptCell.h
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXMusicDetailViewModel;
@class HXInfectView;
@class HXMusicDetailPromptCell;

typedef NS_ENUM(NSUInteger, HXMusicDetailPromptCellAction) {
    HXMusicDetailPromptCellActionInfect,
    HXMusicDetailPromptCellActionFavorite,
    HXMusicDetailPromptCellActionShowInfecter,
    HXMusicDetailPromptCellActionShowFavorite,
};

@protocol HXMusicDetailPromptCellDelegate <NSObject>

@optional
- (void)promptCell:(HXMusicDetailPromptCell *)cell takeAction:(HXMusicDetailPromptCellAction)action;

@end

@interface HXMusicDetailPromptCell : UITableViewCell

@property (weak, nonatomic) IBOutlet                id  <HXMusicDetailPromptCellDelegate>delegate;

@property (weak, nonatomic) IBOutlet      UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet      UILabel *seeCountLabel;
@property (weak, nonatomic) IBOutlet      UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet       UIView *infectInfoView;
@property (weak, nonatomic) IBOutlet HXInfectView *infectView;
@property (weak, nonatomic) IBOutlet      UILabel *infectionCountLabel;
@property (weak, nonatomic) IBOutlet       UIView *favoriteInfoView;
@property (weak, nonatomic) IBOutlet     UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet      UILabel *favoriteCountLabel;
@property (weak, nonatomic) IBOutlet      UILabel *commentCountLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceConstraint;

- (IBAction)favoriteButtonPressed;

- (void)displayWithViewModel:(HXMusicDetailViewModel *)viewModel;

@end
