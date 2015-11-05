//
//  HXRadioCarouselHelper.m
//  mia
//
//  Created by miaios on 15/10/12.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXRadioCarouselHelper.h"
#import "HXRadioView.h"
#import "ShareItem.h"

@interface HXRadioCarouselHelper () <HXRadioViewDelegate> {
	iCarousel *_carousel;
}

@end

@implementation HXRadioCarouselHelper

#pragma mark - Public Methods
- (void)configWithCarousel:(iCarousel *)carousel {
    _carousel = carousel;
    
    carousel.type = iCarouselTypeLinear;
    carousel.pagingEnabled = YES;
    
    carousel.dataSource = self;
    carousel.delegate = self;
}

#pragma mark - Setter And Getter
- (void)setItems:(NSArray *)items {
    _items = items;
    NSLog(@"🐥🐥🐥🐥🐥🐥🐥🐥🐥-----🐥🐥🐥🐥🐥🐥🐥🐥🐥: %@", @(items.count));
    [_carousel reloadData];
}

#pragma mark - iCarousel Data Source Methods
- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    //return the total number of items in the carousel
    return [_items count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    HXRadioView *radioView = nil;
    //create new view if no view is available for recycling
    if (!view){
        view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, carousel.frame.size.width, carousel.frame.size.height)];
        radioView = [HXRadioView initWithFrame:view.bounds delegate:self];
        radioView.tag = 1;
        [view addSubview:radioView];
    } else {
        //get a reference to the label in the recycled view
        radioView = (HXRadioView *)[view viewWithTag:1];
    }
    
    if ((_items.count) && (index < _items.count)) {
        [radioView displayWithItem:_items[index]];
    }
    
    return view;
}

#pragma mark - iCarousel Delegate Methods
- (CGFloat)carousel:(__unused iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    //customize carousel display
    switch (option) {
        case iCarouselOptionWrap: {
            return NO;
            break;
        }
        case iCarouselOptionSpacing: {
            //add a bit of spacing between the item views
            return value * 1.02f;
            break;
        }
        default: {
            return value;
        }
    }
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    if (_items.count) {
        if (_delegate && [_delegate respondsToSelector:@selector(helperDidTaped:)]) {
            [_delegate helperDidTaped:self];
        }
    }
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel {
    NSLog(@"🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥: %@", @(carousel.currentItemIndex));
    if (_items.count) {
        NSLog(@"-----------[carouselDidEndScrollingAnimation]-----------");
        if (_delegate && [_delegate respondsToSelector:@selector(helperShouldPlay:)]) {
            [_delegate helperShouldPlay:self];
        }
    }
}

- (void)carouselDidScroll:(iCarousel *)carousel {
    CGFloat scrollOffset = carousel.scrollOffset;
    CGFloat width = carousel.frame.size.width;
    if (scrollOffset < 0) {
        CGFloat offsetX = fabs(width * scrollOffset);
        if (_delegate && [_delegate respondsToSelector:@selector(helperScrollNoLastest:offsetX:)]) {
            [_delegate helperScrollNoLastest:self offsetX:offsetX];
        }
    } else if (scrollOffset > (carousel.currentItemIndex + 1)) {
        CGFloat offsetX = width * (scrollOffset - carousel.currentItemIndex);
        if (_delegate && [_delegate respondsToSelector:@selector(helperScrollNoNewest:offsetX:)]) {
            [_delegate helperScrollNoNewest:self offsetX:offsetX];
        }
    }
}

#pragma mark - HXRadioViewDelegate Methods
- (void)radioViewStarTapedNeedLogin:(HXRadioView *)radioView {
	if (_delegate && [_delegate respondsToSelector:@selector(helperStarTapedNeedLogin:)]) {
		[_delegate helperStarTapedNeedLogin:self];
	}
}

- (void)radioViewSharerNameTaped:(HXRadioView *)radioView {
	if (_delegate && [_delegate respondsToSelector:@selector(helperSharerNameTaped:)]) {
		[_delegate helperSharerNameTaped:self];
	}
}

- (void)radioViewShouldPlay:(HXRadioView *)radioView {
    if (_delegate && [_delegate respondsToSelector:@selector(helperShouldPlay:)]) {
        [_delegate helperShouldPlay:self];
    }
}

- (void)radioViewShouldPause:(HXRadioView *)radioView {
    if (_delegate && [_delegate respondsToSelector:@selector(helperShouldPause:)]) {
        [_delegate helperShouldPause:self];
    }
}

@end
