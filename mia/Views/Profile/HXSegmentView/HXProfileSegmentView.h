//
//  HXProfileSegmentView.h
//  Mia
//
//  Created by miaios on 15/12/8.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXSegmentItemView.h"

typedef NS_ENUM(NSUInteger, HXProfileSegmentItemType) {
    HXProfileSegmentItemTypeShow,
    HXProfileSegmentItemTypeSongList,
    HXProfileSegmentItemTypeAttention
};

@class HXProfileSegmentView;

@protocol HXProfileSegmentViewDelegate <NSObject>

@required
- (void)segmentView:(HXProfileSegmentView *)segmentView selectedType:(HXProfileSegmentItemType)type;

@end

@interface HXProfileSegmentView : UIView

@property (weak, nonatomic) IBOutlet                id  <HXProfileSegmentViewDelegate>delegate;

@property (weak, nonatomic) IBOutlet HXSegmentItemView *favoriteItemView;
@property (weak, nonatomic) IBOutlet HXSegmentItemView *commentItemView;
@property (weak, nonatomic) IBOutlet HXSegmentItemView *attentionItemView;

@property (weak, nonatomic) IBOutlet UIView *cursorLine;

+ (instancetype)instanceWithDelegate:(id<HXProfileSegmentViewDelegate>)delegate;
- (instancetype)initWithDelegate:(id<HXProfileSegmentViewDelegate>)delegate;

@end
