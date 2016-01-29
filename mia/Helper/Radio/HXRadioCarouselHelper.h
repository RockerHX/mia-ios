//
//  HXRadioCarouselHelper.h
//  mia
//
//  Created by miaios on 15/10/12.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <iCarousel/iCarousel.h>

typedef NS_ENUM(NSUInteger, HXRadioCarouselHelperAction) {
    HXRadioCarouselHelperActionTaped,
    HXRadioCarouselHelperActionPlay,
    HXRadioCarouselHelperActionPause,
    HXRadioCarouselHelperActionSharerTaped,
    HXRadioCarouselHelperActionInfecterTaped,
    HXRadioCarouselHelperActionContentTaped,
    HXRadioCarouselHelperActionStarTaped
};

@class HXRadioCarouselHelper;

@protocol HXRadioCarouselHelperDelegate <NSObject>

@optional
- (void)helper:(HXRadioCarouselHelper *)helper takeAction:(HXRadioCarouselHelperAction)action;

- (void)helperScrollNoLastest:(HXRadioCarouselHelper *)helper offsetX:(CGFloat)offsetX;
- (void)helperScrollNoNewest:(HXRadioCarouselHelper *)helper offsetX:(CGFloat)offsetX;

@end

@class ShareItem;

@interface HXRadioCarouselHelper : NSObject <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, weak)      id  <HXRadioCarouselHelperDelegate>delegate;
@property (nonatomic, copy) NSArray *items;

- (void)configWithCarousel:(iCarousel *)carousel;

@end
