//
//  HXRadioViewController.h
//  mia
//
//  Created by miaios on 15/10/9.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iCarousel/iCarousel.h>

@interface HXRadioViewController : UIViewController <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, strong) IBOutlet iCarousel *carousel;

@end
