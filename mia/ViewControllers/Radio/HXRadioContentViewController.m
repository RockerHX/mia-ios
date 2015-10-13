//
//  HXRadioContentViewController.m
//  mia
//
//  Created by miaios on 15/10/10.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXRadioContentViewController.h"
#import "HXRadioCarouselHelper.h"

@interface HXRadioContentViewController () {
    NSMutableArray *_items;
    HXRadioCarouselHelper *_helper;
    
    CGAffineTransform _transform;
}

@end

@implementation HXRadioContentViewController

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
    _helper.items = _items;
}

- (void)viewConfig {
    [self carouselConfig];
    [self stackViewConfig];
    [self gestureConfig];
    
    _transform = _stackView.transform;
}

- (void)carouselConfig {
    //configure carousel
    _carousel.type = iCarouselTypeLinear;
    _carousel.pagingEnabled = YES;
    
    _carousel.dataSource = _helper;
    _carousel.delegate = _helper;
}

- (void)stackViewConfig {
    for (int i = 0; i < 3; i++) {
        UIImageView *star = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star"]];
        star.contentMode = UIViewContentModeScaleAspectFit;
        [_stackView addArrangedSubview:star];
    }
}

- (void)gestureConfig {
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizer:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionUp;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizer:)];
    panGesture.minimumNumberOfTouches = 1;
    panGesture.maximumNumberOfTouches = 1;
    [panGesture requireGestureRecognizerToFail:swipeGesture];
//    [self.view addGestureRecognizer:swipeGesture];
    [self.view addGestureRecognizer:panGesture];
}

#pragma mark - Event Response
static CGFloat Threshold = 0.0f;
static CGFloat AnimateDuration = 0.5f;
static CGFloat TransformScaleMultiple = 1.5f;
static CGFloat StackViewBottomMaxConstraint = 60.0f;
- (void)gestureRecognizer:(UIGestureRecognizer *)gesture {
    __weak __typeof__(self)weakSelf = self;
    if ([gesture isKindOfClass:[UISwipeGestureRecognizer class]]) {
        [UIView animateWithDuration:AnimateDuration animations:^{
            __strong __typeof__(self)strongSelf = weakSelf;
            if (strongSelf.stackViewBottomConstraint.constant < StackViewBottomMaxConstraint) {
                strongSelf.stackViewBottomConstraint.constant = StackViewBottomMaxConstraint;
                strongSelf.stackView.transform = CGAffineTransformScale(strongSelf.stackView.transform, TransformScaleMultiple, TransformScaleMultiple);
                [strongSelf.view layoutIfNeeded];
            }
        }];
    } else if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gesture;
//        NSLog(@"translationInView:%@", NSStringFromCGPoint([panGesture translationInView:self.view]));
//        NSLog(@"velocityInView:%@", NSStringFromCGPoint([panGesture velocityInView:self.view]));
        CGFloat offsetY = [panGesture translationInView:self.view].y;
        CGFloat rate = fabs(offsetY)/(self.view.frame.size.height/2);
        // 手指向上滑动
        if (offsetY < Threshold) {
            if (self.stackViewBottomConstraint.constant < StackViewBottomMaxConstraint) {
                _stackViewBottomConstraint.constant = StackViewBottomMaxConstraint*rate;
                _stackView.transform = CGAffineTransformScale(_transform, 1+0.5*rate, 1+0.5*rate);
                [self.view layoutIfNeeded];
            }
        }
    }
}

@end
