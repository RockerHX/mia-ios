//
//  HXDiscoveryCover.h
//  mia
//
//  Created by miaios on 16/2/22.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HXDiscoveryCoverAction) {
    HXDiscoveryCoverActionPlay,
    HXDiscoveryCoverActionShowSharer,
    HXDiscoveryCoverActionShowInfecter,
    HXDiscoveryCoverActionShowDetail,
};

@class ShareItem;
@class HXDiscoveryCover;

@protocol HXDiscoveryCoverDelegate <NSObject>

@required
- (void)cover:(HXDiscoveryCover *)cover takeAcion:(HXDiscoveryCoverAction)action;

@end

@interface HXDiscoveryCover : UIView

@property (weak, nonatomic) IBOutlet          id  <HXDiscoveryCoverDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIImageView *cover;
@property (weak, nonatomic) IBOutlet    UIButton *playButton;
@property (weak, nonatomic) IBOutlet     UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet     UILabel *singerNameLabel;

@property (weak, nonatomic) IBOutlet      UIView *cardUserView;
@property (weak, nonatomic) IBOutlet UIImageView *cardUserAvatar;
@property (weak, nonatomic) IBOutlet     UILabel *cardUserLabel;
@property (weak, nonatomic) IBOutlet     UILabel *cardPromptLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarWidthConstraint;

- (IBAction)playAction;
- (IBAction)showProfileAction;
- (IBAction)showDetailAction;

- (void)displayWithItem:(ShareItem *)item;

@end
