//
//  HXProfileListViewModel.m
//  mia
//
//  Created by miaios on 16/1/29.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXProfileListViewModel.h"
#import "MiaAPIHelper.h"
#import "FavoriteMgr.h"

static NSInteger ListPageLimit = 10;

typedef void(^CompletedBlock)(HXProfileListViewModel *);
typedef void(^FailureBlock)(NSString *);

@interface HXProfileListViewModel () <
FavoriteMgrDelegate
>
@end

@implementation HXProfileListViewModel {
    CompletedBlock _completedBlock;
    FailureBlock _failureBlock;
    
    NSInteger _shareListPage;
    NSInteger _favoriteListPage;
    
    NSMutableArray *_shareLists;
    NSMutableArray *_favoriteLists;
}

#pragma mark - Class Methods
+ (instancetype)instanceWithUID:(NSString *)uid {
    HXProfileListViewModel *viewModel = [HXProfileListViewModel new];
    viewModel.uid = uid;
    return viewModel;
}

#pragma mark - Init Methods
- (instancetype)init {
    self = [super init];
    if (self) {
        [self initConfigure];
    }
    return self;
}

#pragma mark - Configure Methods
- (void)initConfigure {
    _shareListPage = 1;
    _favoriteListPage = 1;
    
    _shareLists = @[].mutableCopy;
    _favoriteLists = @[].mutableCopy;
    
    [FavoriteMgr standard].customDelegate = self;
}

#pragma mark - Setter And Getter
- (CGFloat)shareCellHeight {
    return (SCREEN_WIDTH/378.0f) * 232.0f;
}

- (CGFloat)favoriteHeight {
    return 65.0f;
}

- (CGFloat)segmentHeight {
    return 60.0f;
}

- (NSInteger)rows {
    NSInteger rows = 0;
    switch (_itemType) {
        case HXProfileSegmentItemTypeShare: {
            rows = self.dataSource.count;
            break;
        }
        case HXProfileSegmentItemTypeFavorite: {
            rows = _rowTypes.count;
            break;
        }
    }
    return rows;
}

- (NSArray *)dataSource {
    NSArray *lists = nil;
    switch (_itemType) {
        case HXProfileSegmentItemTypeShare: {
            lists = _shareLists.copy;
            break;
        }
        case HXProfileSegmentItemTypeFavorite: {
            lists = _favoriteLists.copy;
            break;
        }
    }
    return lists;
}

- (void)setItemType:(HXProfileSegmentItemType)itemType {
    _itemType = itemType;
    
    switch (itemType) {
        case HXProfileSegmentItemTypeShare: {
            if (_completedBlock) {
                _completedBlock(self);
            }
            break;
        }
        case HXProfileSegmentItemTypeFavorite: {
            [self fetchUserListData];
            break;
        }
    }
}

- (NSInteger)shareCount {
    return _shareLists.count;
}

- (NSInteger)favoriteCount {
    return _favoriteLists.count;
}

#pragma mark - Public Methods
- (void)fetchProfileListData:(void(^)(HXProfileListViewModel *viewModel))completed failure:(void(^)(NSString *message))failure {
    _completedBlock = completed;
    _failureBlock = failure;
    [self fetchUserListData];
}

- (void)fetchProfileListMoreData:(void(^)(HXProfileListViewModel *viewModel))completed failure:(void(^)(NSString *message))failure {
    _completedBlock = completed;
    _failureBlock = failure;
}

- (void)deleteShareItemWithIndex:(NSInteger)index {
    if (index < _shareLists.count) {
        [_shareLists removeObjectAtIndex:index];
    }
}

#pragma mark - Private Methods
- (void)fetchUserListData {
    switch (_itemType) {
        case HXProfileSegmentItemTypeShare: {
            [self fetchUserShareData];
            break;
        }
        case HXProfileSegmentItemTypeFavorite: {
            [self fetchUserFavoriteData];
            break;
        }
    }
}

- (void)fetchUserShareData {
    // 客人态第一个卡片占一行，为了保持最后一行有两个卡片，第一页的请求个数需要加一
    // 当如果这样的话，第二页的个数如果不一样的话，会导致数据重复
    // 第一页11个的最后一个，第二页10个的第一个
    // 解决方案：服务端的start不是分页，而是上一个id
    [MiaAPIHelper getShareListWithUID:_uid
                                start:_shareListPage
                                 item:ListPageLimit
                        completeBlock:
     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
         if (success) {
             NSArray *shareList = userInfo[@"v"][@"info"];
             if ([shareList count] <= 0) {
//                 [[FileLog standard] log:@"Profile requestShareList shareList is nil"];
//                 [self checkPlaceHolder];
                 return;
             }
             
             for(NSDictionary *item in shareList) {
                 ShareItem *shareItem = [[ShareItem alloc] initWithDictionary:item];
                 [_shareLists addObject:shareItem];
             }
             
             ++_shareListPage;
             
             if (_completedBlock) {
                 _completedBlock(self);
             }
         } else {
             id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
             if (_failureBlock) {
                 _failureBlock([NSString stringWithFormat:@"%@", error]);
             }
         }
         
     } timeoutBlock:^(MiaRequestItem *requestItem) {
         if (_failureBlock) {
             _failureBlock(@"无法获取分享列表，网络请求超时");
         }
     }];
}

- (void)fetchUserFavoriteData {
    [[FavoriteMgr standard] syncFavoriteList];
}

#pragma mark - FavoriteMgrDelegate Methods
- (void)favoriteMgrDidFinishSync {
    _favoriteLists = [FavoriteMgr standard].dataSource;
    NSMutableArray *rowTypes = @[@(HXProfileSongRowTypeSongAction)].mutableCopy;
    [_favoriteLists enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [rowTypes addObject:@(HXProfileSongRowTypeSong)];
    }];
    _rowTypes = [rowTypes copy];
    
    if (_completedBlock) {
        _completedBlock(self);
    }
}

@end
