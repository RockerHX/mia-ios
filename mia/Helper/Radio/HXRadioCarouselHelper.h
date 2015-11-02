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

@class HXRadioCarouselHelper;

@protocol HXRadioCarouselHelperDelegate <NSObject>

@optional
- (void)helper:(HXRadioCarouselHelper *)helper shouldChangeMusic:(HXRadioCarouselHelperAction)action;
- (void)helperDidChange:(HXRadioCarouselHelper *)helper;
- (void)helperDidTaped:(HXRadioCarouselHelper *)helper;
- (void)helperShouldPlay:(HXRadioCarouselHelper *)helper;
- (void)helperShouldPause:(HXRadioCarouselHelper *)helper;
- (void)helperSharerNameTaped:(HXRadioCarouselHelper *)helper;
- (void)helperStarTapedNeedLogin:(HXRadioCarouselHelper *)helper;

- (void)helperScrollNoLastest:(HXRadioCarouselHelper *)helper offsetX:(CGFloat)offsetX;
- (void)helperScrollNoNewest:(HXRadioCarouselHelper *)helper offsetX:(CGFloat)offsetX;

@end

@class ShareItem;

@interface HXRadioCarouselHelper : NSObject <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, weak)      id  <HXRadioCarouselHelperDelegate>delegate;
@property (nonatomic, assign)  BOOL  warp;
@property (nonatomic, copy) NSArray *items;

- (void)configWithCarousel:(iCarousel *)carousel;
- (ShareItem *)currentItem;

- (NSInteger)previousItemIndex;
- (NSInteger)nextItemIndex;

@end
