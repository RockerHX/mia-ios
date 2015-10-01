//
//  XiamiHelper.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "MiaAPIMacro.h"
#import "AFNHttpClient.h"

@interface XiamiHelper : NSObject

+ (void)requestSearchSuggestionWithKey:(NSString *)key successBlock:(SuccessBlock)successBlock failedBlock:(FailedBlock)failedBlock;
+ (void)requestSearchResultWithKey:(NSString *)key page:(NSUInteger)page successBlock:(SuccessBlock)successBlock failedBlock:(FailedBlock)failedBlock;
+ (NSString *)decodeXiamiUrl:(NSString *)encodeUrl;

@end
