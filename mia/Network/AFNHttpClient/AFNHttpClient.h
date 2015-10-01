//
//  AFNHttpClient.h
//  mia
//
//  Created by linyehui on 14-11-10.
//  Copyright (c) 2014年 Mia Music. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AFNHttpRequestType) {
    AFNHttpRequestGet,
    AFNHttpRequestPost
};

/**
 *  Handler处理完成后调用的Block
 */
typedef void (^CompleteBlock)();

/**
 *  Handler处理成功时调用的Block
 */
typedef void (^SuccessBlock)(id responseObject);

/**
 *  Handler处理失败时调用的Block
 */
typedef void (^FailedBlock)(NSError *error);

@interface AFNHttpClient : NSObject

/**
 *  封装登录请求
 *
 *  @param url          发送请求的url路径
 *  @param requestTypes 请求的类型
 *  @param parameters   发送请求的参数
 *  @param timeOut      设置连接超时
 *  @param successBlock 返回成功的block
 *  @param failBlock    返回失败的block
 *
 */
+ (id)requestHTMLWithURL:(NSString *)url
              requestType:(AFNHttpRequestType )requestTypes
               parameters:(id )parameters
                  timeOut:(NSTimeInterval )timeOut
             successBlock:(void (^)(id task, id responseObject))successBlock
                failBlock:(void (^)(id task, NSError *error))failBlock;

/**
 *  封装请求（无需上传图片资源）
 *
 *  @param url          发送请求的url路径
 *  @param requestTypes 请求的类型
 *  @param parameters   发送请求的参数
 *  @param timeOut      设置连接超时
 *  @param successBlock 返回成功的block
 *  @param failBlock    返回失败的block
 *
 */
+ (id)requestWithURL:(NSString *)url
         requestType:(AFNHttpRequestType )requestTypes
          parameters:(id )parameters
             timeOut:(NSTimeInterval )timeOut
        successBlock:(void (^)(id task, NSDictionary *jsonServerConfig))successBlock
           failBlock:(void (^)(id task, NSError *error))failBlock;


/**
 *  封装请求（需上传图片资源）
 *
 *  @param url          发送请求的url路径
 *  @param requestTypes 请求的类型
 *  @param parameters   发送请求的参数
 *  @param imageArray   图片资源
 *  @param timeOut      设置连接超时
 *  @param successBlock 返回成功的block
 *  @param failBlock    返回失败的block
 *
 */
+ (id)requestWithURL:(NSString *)url
         requestType:(AFNHttpRequestType )requestTypes
          parameters:(id )parameters
          imageArray:(NSArray *)imageArray
             timeOut:(NSTimeInterval )timeOut
        successBlock:(void (^)(id task, NSDictionary *jsonServerConfig))successBlock
           failBlock:(void (^)(id task, NSError *error))failBlock;

/**
 *  封装同步请求
 *
 *  @param url          发送请求的url路径
 *  @param requestTypes 请求的类型
 *  @param parameters   发送请求的参数
 *  @param timeOut      设置连接超时
 *
 */
+ (NSDictionary *)requestWaitUntilFinishedWithURL:(NSString *)url
									  requestType:(AFNHttpRequestType )requestType
									   parameters:(id)parameters
										  timeOut:(NSTimeInterval )timeOut;


@end








