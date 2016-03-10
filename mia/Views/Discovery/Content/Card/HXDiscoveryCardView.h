//
//  HXDiscoveryCardView.h
//  mia
//
//  Created by miaios on 16/2/18.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXInfectView;
@class HXDiscoveryCover;
@class TTTAttributedLabel;
@class HXDiscoveryCardView;

typedef NS_ENUM(NSUInteger, HXDiscoveryCardViewAction) {
    HXDiscoveryCardViewActionPlay,
    HXDiscoveryCardViewActionShowSharer,
    HXDiscoveryCardViewActionShowInfecter,
    HXDiscoveryCardViewActionShowCommenter,
    HXDiscoveryCardViewActionShowDetailOnly,
    HXDiscoveryCardViewActionShowDetailAndComment,
    HXDiscoveryCardViewActionInfect,
    HXDiscoveryCardViewActionComment
};

@protocol HXDiscoveryCardViewDelegate <NSObject>

@optional
- (void)cardView:(HXDiscoveryCardView *)view takeAction:(HXDiscoveryCardViewAction)action;

@end

@interface HXDiscoveryCardView : UIView

@property (weak, nonatomic) IBOutlet   HXDiscoveryCover *coverView;
@property (weak, nonatomic) IBOutlet             UIView *sharerInfoView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *sharerLabel;
@property (weak, nonatomic) IBOutlet       HXInfectView *infectView;
@property (weak, nonatomic) IBOutlet        UIImageView *favoriteIcon;
@property (weak, nonatomic) IBOutlet            UILabel *favoriteCountLabel;
@property (weak, nonatomic) IBOutlet            UILabel *commentatorsNameLabel;
@property (weak, nonatomic) IBOutlet            UILabel *commentContentLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cverToShareInfoLabelVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareInfoLabelToInfectViewVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infectViewToFavoriteViewVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *favoriteViewToCommentViewVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentViewToSuperViewVerticalSpaceConstraint;

@property (nonatomic, weak) id <HXDiscoveryCardViewDelegate>delegate;

- (IBAction)favoriteAction;
- (IBAction)showCommenterAction;
- (IBAction)showCommentAction;
- (IBAction)showDetailAction;

- (void)displayWithItem:(id)item;

@end
