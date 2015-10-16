//
//  HXRadioViewController.m
//  mia
//
//  Created by miaios on 15/10/10.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXRadioViewController.h"
#import "HXRadioCarouselHelper.h"

@interface HXRadioViewController () <HXRadioCarouselHelperDelegate> {
    NSMutableArray *_items;
    HXRadioCarouselHelper *_helper;
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
    
    [self viewConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
    _items = @[].mutableCopy;
    for (int i = 0; i < 3; i++) {
        [_items addObject:@(i)];
    }
    
    [self setUpHelper];
}

- (void)setUpHelper {
    _helper = [[HXRadioCarouselHelper alloc] init];
    _helper.delegate = self;
    _helper.items = _items;
}

- (void)viewConfig {
    [self carouselConfig];
}

- (void)carouselConfig {
    //configure carousel
    _carousel.type = iCarouselTypeLinear;
    _carousel.pagingEnabled = YES;
    
    _carousel.dataSource = _helper;
    _carousel.delegate = _helper;
}

#pragma mark - Event Response
- (void)gestureRecognizer:(UIGestureRecognizer *)gesture {
}

#pragma mark - HXRadioCarouselHelperDelegate Methods
- (void)musicBarDidSelceted {
    
}

- (void)shouldChangeMusic:(HXRadioCarouselHelperAction)action {
    
}

@end
