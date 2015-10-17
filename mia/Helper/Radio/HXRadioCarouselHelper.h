//
//  HXRadioCarouselHelper.h
//  mia
//
//  Created by miaios on 15/10/12.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <iCarousel/iCarousel.h>

typedef NS_ENUM(NSUInteger, HXRadioCarouselHelperAction) {
    HXRadioCarouselHelperActionPlayCurrent,
    HXRadioCarouselHelperActionPlayPrevious,
    HXRadioCarouselHelperActionPlayNext,
};

@protocol HXRadioCarouselHelperDelegate <NSObject>

@optional
- (void)musicBarDidTaped;
- (void)shouldChangeMusic:(HXRadioCarouselHelperAction)action;

@end

@interface HXRadioCarouselHelper : NSObject <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, weak)      id  <HXRadioCarouselHelperDelegate>delegate;
@property (nonatomic, copy) NSArray *items;

@end
