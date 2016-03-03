//
//  HXProfileViewModel.m
//  mia
//
//  Created by miaios on 16/1/29.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXProfileViewModel.h"
#import "MiaAPIHelper.h"
#import "UIConstants.h"

static NSInteger ListPageLimit = 10;

typedef void(^CompletedBlock)(HXProfileViewModel *);
typedef void(^FailureBlock)(NSString *);

@implementation HXProfileViewModel {
    CompletedBlock _completedBlock;
    FailureBlock _failureBlock;
    
    NSInteger _shareListPage;
    
    NSMutableArray *_shareLists;
}

#pragma mark - Class Methods
+ (instancetype)instanceWithUID:(NSString *)uid {
    HXProfileViewModel *viewModel = [HXProfileViewModel new];
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
    _shareLists = @[].mutableCopy;
}

#pragma mark - Setter And Getter
- (NSInteger)rows {
    return self.dataSource.count;
}

- (NSArray *)dataSource {
    return _shareLists;
}

#pragma mark - Public Methods
- (void)fetchProfileListData:(void(^)(HXProfileViewModel *viewModel))completed failure:(void(^)(NSString *message))failure {
    _completedBlock = completed;
    _failureBlock = failure;

	_shareListPage = 1;
	_shareLists = @[].mutableCopy;

    [self fetchUserListData];
}

- (void)fetchProfileListMoreData {
    [self fetchUserShareData];
}

- (void)fetchUserListData {
    [self fetchUserShareData];
}

- (void)deleteShareItemWithIndex:(NSInteger)index {
    if (index < _shareLists.count) {
        [_shareLists removeObjectAtIndex:index];
    }
}

#pragma mark - Private Methods
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
             if ([shareList count] > 0) {
                 
                 for(NSDictionary *item in shareList) {
                     ShareItem *shareItem = [[ShareItem alloc] initWithDictionary:item];
                     [_shareLists addObject:shareItem];
                 }
                 
                 ++_shareListPage;
             }
             
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

@end
