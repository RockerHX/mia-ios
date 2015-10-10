//
//  HXRadioViewController.m
//  mia
//
//  Created by miaios on 15/10/9.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXRadioViewController.h"

@interface HXRadioViewController () {
    NSMutableArray *_items;
}

@end

@implementation HXRadioViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initConfig];
}

- (void)dealloc {
    _carousel.delegate = nil;
    _carousel.dataSource = nil;
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //configure carousel
    _carousel.type          = iCarouselTypeLinear;
    _carousel.pagingEnabled = YES;
}

#pragma mark - Config Methods
- (void)initConfig {
    _items = @[].mutableCopy;
    for (int i = 0; i < 3; i++) {
        [_items addObject:@(i)];
    }
}

#pragma mark - Event Response

#pragma mark - iCarousel Data Source Methods
- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    //return the total number of items in the carousel
    return [_items count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    UILabel *label = nil;
    //create new view if no view is available for recycling
    if (!view){
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300.0f, 320.0f)];
        view.backgroundColor = [UIColor darkGrayColor];
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [label.font fontWithSize:50];
        label.tag = 1;
        [view addSubview:label];
    } else {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    label.text = [_items[index] stringValue];
    
    return view;
}

#pragma mark - iCarousel Delegate Methods
- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel {
    NSLog(@"Current Page:%@", @(carousel.currentItemIndex));
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"Selected Index:%@", @(index));
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
