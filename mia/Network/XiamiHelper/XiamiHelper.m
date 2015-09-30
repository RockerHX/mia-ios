//
//  XiamiHelper.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//
//

#import "XiamiHelper.h"

@interface XiamiHelper()

@end

@implementation XiamiHelper{
}

/**
 *  请求导航栏场景
 *
 *  @param successBlock 请求成功的回调
 *  @param failedBlock  请求失败的回调
 */
+ (void)requestSearchIndex:(SuccessBlock)successBlock failedBlock:(FailedBlock)failedBlock{
	dispatch_queue_t queue = dispatch_queue_create("RequestSearchIndex", NULL);
	dispatch_async(queue, ^(){
		NSString *requestUrl = @"http://www.xiami.com/ajax/search-index?key=w";
		[AFNHttpClient requestLoginWithURL:requestUrl requestType:AFNHttpRequestPost parameters:nil timeOut:TIMEOUT successBlock:^(id task, id responseObject) {
			if(successBlock){
				successBlock(responseObject);
			}
		} failBlock:^(id task, NSError *error) {
			if(failedBlock){
				failedBlock(error);
			}
		}];
	});
}

@end

