//
//  HXRadioViewController.h
//  mia
//
//  Created by miaios on 15/10/10.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <iCarousel/iCarousel.h>

@class ShareItem;

@protocol HXRadioViewControllerDelegate <NSObject>

@optional
- (void)userWouldLikeSeeSharerHomePageWithItem:(ShareItem *)item;
- (void)userStartNeedLogin;
- (void)shouldDisplayInfectUsers:(ShareItem *)item;
- (void)musicDidChange:(ShareItem *)item;
- (void)raidoViewDidTaped;

@end

@interface HXRadioViewController : UIViewController

@property (weak, nonatomic) IBOutlet 		  id  <HXRadioViewControllerDelegate>delegate;
@property (nonatomic, weak) IBOutlet   iCarousel *carousel;
@property (nonatomic, weak) IBOutlet UIImageView *noMoreLastestLogo;
@property (nonatomic, weak) IBOutlet UIImageView *noMoreNewestLogo;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *noMoreLogoWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *noMoreLastestLogoRightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *noMoreNewestLogoLeftConstraint;

- (void)loadShareList;

@end
