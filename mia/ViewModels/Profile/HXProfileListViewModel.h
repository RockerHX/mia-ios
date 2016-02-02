//
//  HXProfileListViewModel.h
//  mia
//
//  Created by miaios on 16/1/29.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXProfileSegmentView.h"
#import "HXProfileShareCell.h"
#import "HXProfileSongActionCell.h"
#import "HXProfileSongCell.h"

typedef NS_ENUM(NSUInteger, HXProfileSongRowType) {
    HXProfileSongRowTypeSongAction,
    HXProfileSongRowTypeSong
};

@interface HXProfileListViewModel : NSObject

@property (nonatomic, strong)  NSString *uid;

@property (nonatomic, assign, readonly)   CGFloat  shareCellHeight;
@property (nonatomic, assign, readonly)   CGFloat  favoriteHeight;
@property (nonatomic, assign, readonly)   CGFloat  segmentHeight;
@property (nonatomic, assign, readonly) NSInteger  rows;
@property (nonatomic, strong, readonly)   NSArray *rowTypes;
@property (nonatomic, strong, readonly)   NSArray *dataSource;

@property (nonatomic, assign, readonly) NSInteger  favoriteCount;

@property (nonatomic, assign) HXProfileSegmentItemType  itemType;

+ (instancetype)instanceWithUID:(NSString *)uid;

- (void)fetchProfileListData:(void(^)(HXProfileListViewModel *viewModel))completed failure:(void(^)(NSString *message))failure;
- (void)fetchProfileListMoreData;
- (void)fetchUserListData;

- (void)deleteShareItemWithIndex:(NSInteger)index;

@end
