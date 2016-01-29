//
//  HXProfileListViewModel.h
//  mia
//
//  Created by miaios on 16/1/29.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXProfileSegmentView.h"
#import "HXProfileShareCell.h"

@interface HXProfileListViewModel : NSObject

@property (nonatomic, strong)  NSString *uid;

@property (nonatomic, assign, readonly)   CGFloat  shareCellHeight;
@property (nonatomic, assign, readonly)   CGFloat  segmentHeight;
@property (nonatomic, assign, readonly) NSInteger  rows;
@property (nonatomic, strong, readonly)   NSArray *dataSource;

@property (nonatomic, assign, readonly) NSInteger  shareCount;

@property (nonatomic, assign) HXProfileSegmentItemType  itemType;

+ (instancetype)instanceWithUID:(NSString *)uid;

- (void)fetchProfileListData:(void(^)(HXProfileListViewModel *viewModel))completed failure:(void(^)(NSString *message))failure;
- (void)fetchProfileListMoreData:(void(^)(HXProfileListViewModel *viewModel))completed failure:(void(^)(NSString *message))failure;

- (void)deleteShareItemWithIndex:(NSInteger)index;

@end
