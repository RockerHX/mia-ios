//
//  HXProfileViewModel.h
//  mia
//
//  Created by miaios on 16/1/29.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXProfileShareCell.h"

@interface HXProfileViewModel : NSObject

@property (nonatomic, strong)  NSString *uid;

@property (nonatomic, assign, readonly) NSInteger  rows;
@property (nonatomic, strong, readonly)   NSArray *dataSource;

+ (instancetype)instanceWithUID:(NSString *)uid;

- (void)fetchProfileListData:(void(^)(HXProfileViewModel *viewModel))completed failure:(void(^)(NSString *message))failure;
- (void)fetchProfileListMoreData;
- (void)fetchUserListData;

- (void)deleteShareItemWithIndex:(NSInteger)index;

@end
