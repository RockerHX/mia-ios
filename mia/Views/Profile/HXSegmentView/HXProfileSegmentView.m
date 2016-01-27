//
//  HXProfileSegmentView.m
//  Mia
//
//  Created by miaios on 15/12/8.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXProfileSegmentView.h"
#import "HXSegmentItemView.h"
#import "HXXib.h"

@interface HXProfileSegmentView () <HXSegmentItemViewDelegate>
@end

@implementation HXProfileSegmentView

HXXibImplementation

#pragma mark - Class Methods
+ (instancetype)instanceWithDelegate:(id<HXProfileSegmentViewDelegate>)delegate {
    return [[HXProfileSegmentView alloc] initWithDelegate:delegate];
}

#pragma mark - Init Methods
- (instancetype)initWithDelegate:(id<HXProfileSegmentViewDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}

#pragma mark - HXSegmentItemViewDelegate Methods
- (void)itemViewSelected:(HXSegmentItemView *)itemView {
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.2f animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf.cursorLine.center = CGPointMake(itemView.center.x, strongSelf.cursorLine.center.y);
    }];
    
    HXProfileSegmentItemType type = HXProfileSegmentItemTypeShow;
    if ([itemView isEqual:_commentItemView]) {
        type = HXProfileSegmentItemTypeSongList;
    } else if ([itemView isEqual:_attentionItemView]) {
        type = HXProfileSegmentItemTypeAttention;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(segmentView:selectedType:)]) {
        [_delegate segmentView:self selectedType:type];
    }
}

@end
