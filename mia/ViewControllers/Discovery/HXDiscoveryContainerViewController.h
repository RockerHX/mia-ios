//
//  HXDiscoveryContainerViewController.h
//  mia
//
//  Created by miaios on 16/2/17.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class iCarousel;
@class HXDiscoveryContainerViewController;

typedef NS_ENUM(NSUInteger, HXDiscoveryCardAction) {
    HXDiscoveryCardActionSlidePrevious,
    HXDiscoveryCardActionSlideNext,
    HXDiscoveryCardActionPlay
};

@protocol HXDiscoveryContainerViewControllerDelegate <NSObject>

@optional
- (void)containerViewController:(HXDiscoveryContainerViewController *)container takeAction:(HXDiscoveryCardAction)action;

@end

@interface HXDiscoveryContainerViewController : UIViewController

@property (weak, nonatomic) IBOutlet iCarousel *carousel;

@property (nonatomic, weak)          id  <HXDiscoveryContainerViewControllerDelegate>delegate;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong)   NSArray *dataSoure;

@end
