//
//  AFNHttpClient.m
//  mia
//
//  Created by linyehui on 14-11-10.
//  Copyright (c) 2014年 Mia Music. All rights reserved.
//

#import "AFNHttpClient.h"
#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperation.h"
#include <netdb.h>

@interface AFNHttpClient()

@property (strong, nonatomic)AFHTTPSessionManager *manager;

@end

@implementation AFNHttpClient

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
           failBlock:(void (^)(id task, NSError *error))failBlock{
    return [self requestWithURL:url
                    requestType:requestTypes
                     parameters:parameters
                     imageArray:nil
                        timeOut:timeOut
                   successBlock:successBlock
                      failBlock:failBlock];
}

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
                failBlock:(void (^)(id task, NSError *error))failBlock{
    AFNHttpClient *client = [[self alloc] initUsingHTMLWithURL:url
                                               requestType:requestTypes
                                                parameters:parameters
                                                   timeOut:timeOut
                                              successBlock:successBlock
                                                 failBlock:failBlock];
    return client;
}

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
           failBlock:(void (^)(id task, NSError *error))failBlock{
    AFNHttpClient *client = [[self alloc] initWithURL:url
                                          requestType:requestTypes
                                           parameters:parameters
                                           imageArray:imageArray
                                              timeOut:timeOut
                                         successBlock:successBlock
                                            failBlock:failBlock];
    return client;
}


+ (NSDictionary *)requestWaitUntilFinishedWithURL:(NSString *)url
									  requestType:(AFNHttpRequestType )requestType
									   parameters:(id)parameters
{
	NSString *method = (requestType == AFNHttpRequestGet) ? @"GET" : @"POST";
	NSError *error = nil;

	AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
	NSMutableURLRequest *request = [requestSerializer requestWithMethod:method URLString:url parameters:parameters error:&error];

	/* 最终继承自 NSOperation，看到这个，大家可能就知道了怎么实现同步的了，也就是利用 NSOperation 来做的同步请求 */
	AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	AFHTTPResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];

	[requestOperation setResponseSerializer:responseSerializer];

	[requestOperation start];

	[requestOperation waitUntilFinished];

	/* 请求结果 */
	NSDictionary *result = (NSDictionary *)[requestOperation responseObject];

	if (result != nil) {

		return result;
	}
	return nil;
}

- (id)initWithURL:(NSString *)url requestType:(AFNHttpRequestType )requestTypes
       parameters:(id )parameters
       imageArray:(NSArray *)imageArray
          timeOut:(NSTimeInterval )timeOut
     successBlock:(void (^)(id task, NSDictionary *jsonServerConfig))successBlock
        failBlock:(void (^)(id task, NSError *error))failBlock{
    self = [super init];
    if(self){
        if([self isConnectionAvailable]){
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
            config.timeoutIntervalForRequest = timeOut;
            config.timeoutIntervalForResource = timeOut;
            AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/html", @"application/json", nil];
            
            NSDictionary *tempParameters = (NSDictionary *)parameters;
            NSMutableDictionary *mutableParameter;
            if(tempParameters != nil){
                mutableParameter = [tempParameters mutableCopy];
            }else{
                mutableParameter = [[NSMutableDictionary alloc] init];
            }
            [mutableParameter setObject:@"ios" forKey:@"platform"];
            NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            [mutableParameter setObject:version forKey:@"version"];
            [mutableParameter setObject:@"v2" forKey:@"apiversion"];
            
            switch (requestTypes) {
                case AFNHttpRequestGet:
                    [manager GET:url parameters:mutableParameter success:successBlock failure:failBlock];
                    break;
                case AFNHttpRequestPost:
                    if(imageArray){
                        [manager POST:url parameters:mutableParameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                            for(int i = 0 ; i < imageArray.count; i ++){
                                NSData *data = [imageArray objectAtIndex:i];
                                NSString *fileName = [NSString stringWithFormat:@"image%d.jpg",i];
                                [formData appendPartWithFileData:data
                                                            name:@"imgs"
                                                        fileName:fileName
                                                        mimeType:@"image/jpeg"];
                            }
                        } success:successBlock failure:failBlock];
                    }else{
                        [manager POST:url parameters:mutableParameter success:successBlock failure:failBlock];
                    }
                    break;
                default:
                    break;
            }
        }else{
            //网络异常
            NSLog(@"网络异常");
        }
    }
    return self;
}


- (id)initUsingHTMLWithURL:(NSString *)url requestType:(AFNHttpRequestType )requestTypes
            parameters:(id )parameters
               timeOut:(NSTimeInterval )timeOut
          successBlock:(void (^)(id task, id responseObject))successBlock
             failBlock:(void (^)(id task, NSError *error))failBlock{
    self = [super init];
    if(self){
        if([self isConnectionAvailable]){
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
            config.timeoutIntervalForRequest = timeOut;
            config.timeoutIntervalForResource = timeOut;
            AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
            //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/html", @"application/json", nil];
			manager.responseSerializer = [AFHTTPResponseSerializer serializer];
			manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
            
            switch (requestTypes) {
                case AFNHttpRequestGet:
                    [manager GET:url parameters:parameters success:successBlock failure:failBlock];
                    break;
                case AFNHttpRequestPost:
                    [manager POST:url parameters:parameters success:successBlock failure:failBlock];
                    break;
                default:
                    break;
            }
        }else{
            //网络异常
            NSLog(@"网络异常");
        }
    }
    return self;
}


/**
 *  判断网络连接是否正常
 *
 */
- (BOOL)isConnectionAvailable{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
//        DLog(@"Error. Could not recover network reachability flags");
        return NO;
    }
    BOOL isReachable = ((flags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
    return (isReachable && !needsConnection) ? YES : NO;
}
@end






















