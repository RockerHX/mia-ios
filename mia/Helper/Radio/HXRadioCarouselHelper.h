//
//  HXRadioCarouselHelper.h
//  mia
//
//  Created by miaios on 15/10/12.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <iCarousel/iCarousel.h>

@interface HXRadioCarouselHelper : NSObject <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, copy) NSArray *items;

@end
