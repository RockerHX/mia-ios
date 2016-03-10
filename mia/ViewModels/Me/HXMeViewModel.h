//
//  HXMeViewModel.h
//  mia
//
//  Created by miaios on 16/1/29.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXMeShareCell.h"

@interface HXMeViewModel : NSObject

@property (nonatomic, assign, readonly) NSInteger  rows;
@property (nonatomic, strong, readonly)   NSArray *dataSource;

- (void)fetchProfileListData:(void(^)(HXMeViewModel *viewModel))completed failure:(void(^)(NSString *message))failure;
- (void)fetchProfileListMoreData;
- (void)fetchUserListData;

- (void)deleteShareItemWithIndex:(NSInteger)index;

@end
