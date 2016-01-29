//
//  HXProfileSegmentView.h
//  Mia
//
//  Created by miaios on 15/12/8.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXSegmentItemView.h"

typedef NS_ENUM(NSUInteger, HXProfileSegmentItemType) {
    HXProfileSegmentItemTypeShare,
    HXProfileSegmentItemTypeFavorite
};

@class HXProfileSegmentView;

@protocol HXProfileSegmentViewDelegate <NSObject>

@required
- (void)segmentView:(HXProfileSegmentView *)segmentView selectedType:(HXProfileSegmentItemType)type;

@end

@interface HXProfileSegmentView : UIView

@property (weak, nonatomic) IBOutlet                id  <HXProfileSegmentViewDelegate>delegate;

@property (weak, nonatomic) IBOutlet HXSegmentItemView *shareItemView;
@property (weak, nonatomic) IBOutlet HXSegmentItemView *favoriteItemView;
@property (weak, nonatomic) IBOutlet            UIView *cursorLine;

@property (nonatomic, assign, readonly) HXProfileSegmentItemType  itemType;

+ (instancetype)instanceWithDelegate:(id<HXProfileSegmentViewDelegate>)delegate;
- (instancetype)initWithDelegate:(id<HXProfileSegmentViewDelegate>)delegate;

@end
