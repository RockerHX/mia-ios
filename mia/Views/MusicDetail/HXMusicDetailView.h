//
//  HXMusicDetailView.h
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShareItem;
@class HXInfectUserView;
@class TTTAttributedLabel;

@class HXMusicDetailView;

@protocol HXMusicDetailViewDelegate <NSObject>

@optional
- (void)detailViewUserWouldStar:(HXMusicDetailView *)detailView;

@end

@interface HXMusicDetailView : UIView

@property (nonatomic, weak) IBOutlet                 id  <HXMusicDetailViewDelegate>delegate;

@property (weak, nonatomic) IBOutlet        UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet           UIButton *playButton;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *songInfoLabel;
@property (weak, nonatomic) IBOutlet           UIButton *starButton;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *shareInfoLabel;
@property (weak, nonatomic) IBOutlet   HXInfectUserView *infectUserView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *infectPromptLabel;
@property (weak, nonatomic) IBOutlet            UILabel *viewCountLabel;
@property (weak, nonatomic) IBOutlet            UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet            UILabel *commentCountLabel;


- (IBAction)playButtonPressed;
- (IBAction)starButtonPressed;

- (void)refreshWithItem:(ShareItem *)item;
- (void)updateStarState:(BOOL)star;

@end
