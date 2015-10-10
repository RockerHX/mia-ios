//
//  HXRadioContentViewController.h
//  mia
//
//  Created by miaios on 15/10/10.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iCarousel/iCarousel.h>

@interface HXRadioContentViewController : UIViewController <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, weak) IBOutlet iCarousel *carousel;
@property (nonatomic, weak) IBOutlet UIStackView *stackView;

@end
