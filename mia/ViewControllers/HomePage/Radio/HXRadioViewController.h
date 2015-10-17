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
- (void)userStarNeedLogin;

@end

@interface HXRadioViewController : UIViewController

@property (weak, nonatomic) IBOutlet 		id  <HXRadioViewControllerDelegate>delegate;
@property (nonatomic, weak) IBOutlet iCarousel *carousel;

- (void)loadShareList;

@end
