//
//  HXRadioCarouselHelper.m
//  mia
//
//  Created by miaios on 15/10/12.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXRadioCarouselHelper.h"
#import "HXRadioView.h"

@implementation HXRadioCarouselHelper

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
    radioView.songNameLabel.text = [_items[index] stringValue];
    
    return view;
}

#pragma mark - iCarousel Delegate Methods
- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    HXRadioCarouselHelperAction playAction = HXRadioCarouselHelperActionPlayCurrent;
    if (carousel.currentItemIndex == 0) {
        if (carousel.scrollOffset > 2) {
            playAction = HXRadioCarouselHelperActionPlayNext;
        } else if (carousel.scrollOffset < 1) {
            playAction = HXRadioCarouselHelperActionPlayPrevious;
        }
    } else {
        if (carousel.scrollOffset > carousel.currentItemIndex) {
            playAction = HXRadioCarouselHelperActionPlayPrevious;
        } else if (carousel.scrollOffset < carousel.currentItemIndex) {
            playAction = HXRadioCarouselHelperActionPlayNext;
        }
    }
    if (_delegate && [_delegate respondsToSelector:@selector(shouldChangeMusic:)]) {
        [_delegate shouldChangeMusic:playAction];
    }
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    if (_delegate && [_delegate respondsToSelector:@selector(musicBarDidTaped)]) {
        [_delegate musicBarDidTaped];
    }
}

- (CGFloat)carousel:(__unused iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    //customize carousel display
    switch (option) {
        case iCarouselOptionWrap: {
            return YES;
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
