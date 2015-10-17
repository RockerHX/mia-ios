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

@implementation HXRadioCarouselHelper {
    iCarousel *_carousel;
}

#pragma mark - Public Methods
- (void)configWithCarousel:(iCarousel *)carousel {
    _carousel = carousel;
    
    carousel.type = iCarouselTypeLinear;
    carousel.pagingEnabled = YES;
    
    carousel.dataSource = self;
    carousel.delegate = self;
}

#pragma mark - Setter And Getter
- (void)setWarp:(BOOL)warp {
    _warp = warp;
//    [_carousel reloadData];
}

- (void)setItems:(NSArray *)items {
    _items = [items copy];
    ShareItem *currentItem = items[0];
    ShareItem *nextItem = items[1];
    ShareItem *preiousItem = items[2];
    NSInteger currentIndex = _carousel.currentItemIndex;
    NSLog(@"currentIndex：%zd", currentIndex);
    switch (currentIndex) {
        case 1: {
            _items = @[preiousItem, currentItem, nextItem];
            break;
        }
        case 2: {
            _items = @[nextItem, preiousItem, currentItem];
            break;
        }
    }
    [_carousel reloadData];
}

#pragma mark - Private Methods
- (NSInteger)previousItemIndex {
    if (_carousel.currentItemIndex == 0) {
        return 2;
    } else {
        return _carousel.currentItemIndex - 1;
    }
}

- (NSInteger)nextItemIndex {
    if (_carousel.currentItemIndex == 2) {
        return 0;
    } else {
        return _carousel.currentItemIndex + 1;
    }
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
        radioView = [HXRadioView initWithFrame:view.bounds delegate:nil];
        radioView.tag = 1;
        [view addSubview:radioView];
    } else {
        //get a reference to the label in the recycled view
        radioView = (HXRadioView *)[view viewWithTag:1];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    if (_items.count) {
        [radioView displayWithItem:_items[index]];
    }
    
    return view;
}

#pragma mark - iCarousel Delegate Methods
- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    CGFloat scrollOffset = carousel.scrollOffset;
    NSInteger currentIndex = carousel.currentItemIndex;
    HXRadioCarouselHelperAction playAction = HXRadioCarouselHelperActionPlayCurrent;
    if (currentIndex == 0) {
        if (scrollOffset > 2) {
            playAction = HXRadioCarouselHelperActionPlayNext;
        } else if (scrollOffset < 1 && scrollOffset > 0) {
            playAction = HXRadioCarouselHelperActionPlayPrevious;
        }
    } else if (currentIndex == 1 || currentIndex == 2) {
        if (scrollOffset > currentIndex) {
            playAction = HXRadioCarouselHelperActionPlayPrevious;
        } else if (scrollOffset < currentIndex) {
            playAction = HXRadioCarouselHelperActionPlayNext;
        }
    }
    if (_delegate && [_delegate respondsToSelector:@selector(helper:shouldChangeMusic:)]) {
        [_delegate helper:self shouldChangeMusic:playAction];
    }
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    if (_delegate && [_delegate respondsToSelector:@selector(helperDidTaped:)]) {
        [_delegate helperDidTaped:self];
    }
}

- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate {
    if (_delegate && [_delegate respondsToSelector:@selector(helperDidChange:)]) {
        [_delegate helperDidChange:self];
    }
}

- (CGFloat)carousel:(__unused iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    //customize carousel display
    switch (option) {
        case iCarouselOptionWrap: {
            return _warp;
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

@end
