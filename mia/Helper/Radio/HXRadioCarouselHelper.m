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
    BOOL _canChange;
    BOOL _firstLoad;
}

@end

@implementation HXRadioCarouselHelper

- (instancetype)init {
    self = [super init];
    if (self) {
        _firstLoad = YES;
    }
    return self;
}

#pragma mark - Public Methods
- (void)configWithCarousel:(iCarousel *)carousel {
    _carousel = carousel;
    
    carousel.type = iCarouselTypeLinear;
    carousel.pagingEnabled = YES;
    
    carousel.dataSource = self;
    carousel.delegate = self;
}

- (ShareItem *)currentItem {
    NSInteger currentIndex = _carousel.currentItemIndex;
    return ((currentIndex >=0) && (currentIndex <= 2)) ? _items[currentIndex] : [ShareItem new];
}

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

#pragma mark - Setter And Getter
- (void)setWarp:(BOOL)warp {
    _warp = warp;
}

- (void)setItems:(NSArray *)items {
    if (items.count >= 3) {
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
        _canChange = NO;
        [_carousel reloadData];
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
        radioView = [HXRadioView initWithFrame:view.bounds delegate:self];
        radioView.tag = 1;
        [view addSubview:radioView];
    } else {
        //get a reference to the label in the recycled view
        radioView = (HXRadioView *)[view viewWithTag:1];
    }
    
    if (_items.count) {
        [radioView displayWithItem:_items[index]];
    }
    
    return view;
}

#pragma mark - iCarousel Delegate Methods
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

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    if (_delegate && [_delegate respondsToSelector:@selector(helperDidTaped:)]) {
        [_delegate helperDidTaped:self];
    }
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    NSLog(@"------[carouselCurrentItemIndexDidChange]");
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
    _canChange = YES;
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel {
    NSLog(@"~~~~~~~~~~~~~First:%@", _firstLoad ? @"YES": @"NO");
    NSLog(@"~~~~~~~~~~~~~Can:%@", _canChange ? @"YES": @"NO");
    if (!_firstLoad) {
        if (_canChange) {
            NSLog(@"------[carouselDidEndScrollingAnimation]");
            if (_delegate && [_delegate respondsToSelector:@selector(helperDidChange:)]) {
                [_delegate helperDidChange:self];
            }
        }
    }
    _firstLoad = NO;
}

#pragma mark - HXRadioViewDelegate Methods
- (void)radioViewDidLoad:(HXRadioView *)radioView item:(ShareItem *)item {
	if ([_items[_carousel.currentItemIndex] isEqual:item]) {
		if (_delegate && [_delegate respondsToSelector:@selector(helperShouldPlay:)]) {
			[_delegate helperShouldPlay:self];
		}
	}
}

- (void)starTapedNeedLogin {
	if (_delegate && [_delegate respondsToSelector:@selector(helperStarTapedNeedLogin:)]) {
		[_delegate helperStarTapedNeedLogin:self];
	}
}

- (void)sharerNameTaped {
	if (_delegate && [_delegate respondsToSelector:@selector(helperSharerNameTaped:)]) {
		[_delegate helperSharerNameTaped:self];
	}
}

@end
