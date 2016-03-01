//
//  HXDiscoveryContainerViewController.m
//  mia
//
//  Created by miaios on 16/2/17.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXDiscoveryContainerViewController.h"
#import "UIView+Frame.h"
#import "iCarousel.h"
#import "HXDiscoveryCardView.h"

@interface HXDiscoveryContainerViewController () <
iCarouselDataSource,
iCarouselDelegate,
HXDiscoveryCardViewDelegate
>
@end

@implementation HXDiscoveryContainerViewController

#pragma mark - View Controller Lift Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    ;
}

- (void)viewConfigure {
    // Configure iCarousel
    _carousel.type = iCarouselTypeLinear;
    _carousel.pagingEnabled = YES;
}

#pragma mark - Property
- (void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage;
    
    [_carousel scrollToItemAtIndex:currentPage animated:NO];
    [_carousel reloadData];
}

- (void)setDataSoure:(NSArray *)dataSoure {
    _dataSoure = dataSoure;
    
    [_carousel reloadData];
}

- (ShareItem *)currentItem {
    return _dataSoure[_carousel.currentItemIndex];
}

#pragma mark - Private Methods
- (UIView *)setupCarouselCard:(iCarousel *)carousel {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, carousel.width - 50.0f, carousel.height - 40.0f)];
    view.layer.shadowColor = [UIColor grayColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
    view.layer.shadowRadius = 3.0f;
    view.layer.shadowOpacity = 1.0f;
    return view;
}

- (HXDiscoveryCardView *)setUpCardView:(UIView *)superView {
    HXDiscoveryCardView *cardView = [[HXDiscoveryCardView alloc] initWithFrame:superView.bounds];
    cardView.delegate = self;
    cardView.tag = 1;
    [superView addSubview:cardView];
    return cardView;
}

#pragma mark - iCarousel Data Source Methods
- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return [_dataSoure count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    HXDiscoveryCardView *cardView = nil;
    //create new view if no view is available for recycling
    if (!view){
        view = [self setupCarouselCard:carousel];
        cardView = [self setUpCardView:view];
    } else {
        //get a reference to the label in the recycled view
        cardView = (HXDiscoveryCardView *)[view viewWithTag:1];
    }
    
    if ((_dataSoure.count) && (index < _dataSoure.count)) {
        [cardView displayWithItem:_dataSoure[index]];
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
            return value * 1.04f;
            break;
        }
        default: {
            return value;
        }
    }
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    if (_carousel.currentItemIndex < _dataSoure.count) {
        if (_delegate && [_delegate respondsToSelector:@selector(containerViewController:takeAction:)]) {
            [_delegate containerViewController:self takeAction:HXDiscoveryCardActionShowDetail];
        }
    }
}

- (void)carouselDidEndDecelerating:(iCarousel *)carousel {
    NSInteger page = carousel.currentItemIndex;
    if (page < _currentPage) {
        _currentPage = page;
        if (_delegate && [_delegate respondsToSelector:@selector(containerViewController:takeAction:)]) {
            [_delegate containerViewController:self takeAction:HXDiscoveryCardActionSlidePrevious];
        }
    } else if (page > _currentPage) {
        _currentPage = page;
        if (_delegate && [_delegate respondsToSelector:@selector(containerViewController:takeAction:)]) {
            [_delegate containerViewController:self takeAction:HXDiscoveryCardActionSlideNext];
        }
    }
}

#pragma mark - HXDiscoveryCardViewDelegate Methods
- (void)cardView:(HXDiscoveryCardView *)view takeAction:(HXDiscoveryCardViewAction)action {
    HXDiscoveryCardAction cardAction = HXDiscoveryCardActionPlay;
    switch (action) {
        case HXDiscoveryCardViewActionPlay: {
            break;
        }
        case HXDiscoveryCardViewActionShowSharer: {
            cardAction = HXDiscoveryCardActionShowSharer;
            break;
        }
        case HXDiscoveryCardViewActionShowInfecter: {
            cardAction = HXDiscoveryCardActionShowInfecter;
            break;
        }
        case HXDiscoveryCardViewActionShowCommenter: {
            cardAction = HXDiscoveryCardActionShowCommenter;
            break;
        }
        case HXDiscoveryCardViewActionShowDetail: {
            cardAction = HXDiscoveryCardActionShowDetail;
            break;
        }
        case HXDiscoveryCardViewActionInfect: {
            cardAction = HXDiscoveryCardActionInfect;
            break;
        }
        case HXDiscoveryCardViewActionComment: {
            cardAction = HXDiscoveryCardActionComment;
            break;
        }
    }
    if (_delegate && [_delegate respondsToSelector:@selector(containerViewController:takeAction:)]) {
        [_delegate containerViewController:self takeAction:cardAction];
    }
}

@end
