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

+ (void)requestSearchIndex:(SuccessBlock)successBlock failedBlock:(FailedBlock)failedBlock;

@end
