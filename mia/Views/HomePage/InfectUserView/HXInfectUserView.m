//
//  HXInfectUserView.m
//  mia
//
//  Created by miaios on 15/10/20.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXInfectUserView.h"
#import "HXInfectUserItemView.h"
#import "UIView+Frame.h"

static CGFloat ItemDefaultWidth = 42.0f;

@implementation HXInfectUserView

#pragma mark - Init Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initConfig];
    [self viewConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
    _itemWidth = ItemDefaultWidth;
}

- (void)viewConfig {
    self.backgroundColor = [UIColor clearColor];
    [self configStackView];
}

- (void)configStackView {
    _stacView.backgroundColor = [UIColor clearColor];
    _stacView.alignment = UIStackViewAlignmentCenter;
    _stacView.distribution = UIStackViewDistributionFillEqually;
}

#pragma mark - Public Methods
- (void)refresh {
    [_stacView layoutIfNeeded];
}

- (void)refreshItemWithAnimation {
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.4f delay:0.0f usingSpringWithDamping:0.7f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        NSArray *subViews = strongSelf.stacView.arrangedSubviews;
        for (HXInfectUserItemView *itemView in subViews) {
            [itemView reduce];
        }
    } completion:nil];
}

- (void)showWithItems:(NSArray *)items {
    _widthConstraint.constant = items.count*_itemWidth;
    for (id item in items) {
        HXInfectUserItemView *itemView = [HXInfectUserItemView instance];
        [_stacView addArrangedSubview:itemView];
        if ([item isKindOfClass:[NSString class]]) {
            NSString *imageName = item;
            [itemView displayWithImageName:imageName];
        } else if ([item isKindOfClass:[NSURL class]]) {
            NSURL *imageURL = item;
            [itemView displayWithURL:imageURL];
        }
    }
}


- (void)addItem:(id)item {
    HXInfectUserItemView *itemView = [HXInfectUserItemView instance];
    itemView.height = self.height;
    itemView.width = itemView.height;
    [_stacView addArrangedSubview:itemView];
    [self refreshItemView:itemView withItem:item];
    [self reCountWidth];
}

- (void)addItems:(NSArray *)items {
    ;
}

- (void)addItem:(id)item atIndex:(NSInteger)index {
    ;
}

- (void)addItem:(id)item atIndex:(NSInteger)index animated:(BOOL)animated {
    ;
}

- (void)addItemAtFirstIndex:(id)item {
    if (_stacView.arrangedSubviews.count == 5) {
        UIView *view = [_stacView.arrangedSubviews lastObject];
        [_stacView removeArrangedSubview:view];
        [view removeFromSuperview];
    }
    HXInfectUserItemView *itemView = [HXInfectUserItemView instance];
    [_stacView insertArrangedSubview:itemView atIndex:0];
    [self refreshItemView:itemView withItem:item];
    [self reCountWidth];
}

- (void)addItemAtLastIndex:(id)item {
    [self addItem:item];
}

- (void)removeAllItem {
    NSArray *subViews = _stacView.arrangedSubviews;
    for (UIView *view in subViews) {
        [_stacView removeArrangedSubview:view];
        [view removeFromSuperview];
    }
}

- (void)removeItem:(id)item atIndex:(NSInteger)index {
    ;
}

- (void)removeItemAtFirstIndex:(id)item {
    ;
}

- (void)removeItemAtLastIndex:(id)item {
    ;
}

#pragma mark - Private Methods
- (void)reCountWidth {
    _widthConstraint.constant = _stacView.arrangedSubviews.count*_itemWidth;
}

- (void)refreshItemView:(HXInfectUserItemView *)itemView withItem:(id)item {
    if ([item isKindOfClass:[NSString class]]) {
        NSString *imageName = item;
        [itemView displayWithImageName:imageName];
    } else if ([item isKindOfClass:[NSURL class]]) {
        NSURL *imageURL = item;
        [itemView displayWithURL:imageURL];
    }
}

@end
