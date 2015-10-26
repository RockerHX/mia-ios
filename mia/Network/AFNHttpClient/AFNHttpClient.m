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

+ (id)postLogDataWithURL:(NSString *)url
				 logData:(NSData *)logData
			  timeOut:(NSTimeInterval )timeOut
		 successBlock:(void (^)(id task, NSDictionary *jsonServerConfig))successBlock
			failBlock:(void (^)(id task, NSError *error))failBlock {
	AFNHttpClient *client = [[self alloc] initWithURL:url
										  requestType:AFNHttpRequestPost
										   logData:logData
											  timeOut:timeOut
										 successBlock:successBlock
											failBlock:failBlock];
	return client;
}

+ (NSDictionary *)requestWaitUntilFinishedWithURL:(NSString *)url
									  requestType:(AFNHttpRequestType )requestType
									   parameters:(id)parameters
										  timeOut:(NSTimeInterval )timeOut
{
	NSString *method = (requestType == AFNHttpRequestGet) ? @"GET" : @"POST";
	NSError *error = nil;

	AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
	NSMutableURLRequest *request = [requestSerializer requestWithMethod:method URLString:url parameters:parameters error:&error];
	[request setTimeoutInterval:timeOut];

	AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	AFHTTPResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];

	[requestOperation setResponseSerializer:responseSerializer];
	[requestOperation start];
	[requestOperation waitUntilFinished];

	NSDictionary *result = (NSDictionary *)[requestOperation responseObject];
	if (result != nil) {
		return result;
	}
	
	return nil;
}

+ (NSURLSessionDownloadTask *)downloadWithURL:(NSString *)url
			   savePath:(NSString *)savePath
		  completeBlock:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completeBlock {
	NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
	AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];

	NSURL *requestUrl = [NSURL URLWithString:url];
	NSURLRequest *request = [NSURLRequest requestWithURL:requestUrl];

	NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request
																	 progress:nil
																  destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
		return [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", savePath]];
	} completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
		if (completeBlock) {
			completeBlock(response, filePath, error);
		}

		NSLog(@"File downloaded to: %@", filePath);
	}];
	[downloadTask resume];

	return downloadTask;
}

#pragma mark - private method
/*
 - (void)customSecurityPolicy {
 @try {

NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"server" ofType:@"cer"];                    // 获取cer秘钥文件路径
NSData *certData = [NSData dataWithContentsOfFile:cerPath];
AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
securityPolicy.allowInvalidCertificates = NO;                                                           // 不允许使用无效证书
securityPolicy.pinnedCertificates = @[certData];

self.securityPolicy = securityPolicy;
//        self.requestSerializer.cachePolicy = NSURLRequestReloadRevalidatingCacheData;
}
@catch (NSException *exception) {
	NSLog(@"%s:%@", __FUNCTION__, exception.reason);
}
@finally {
}
}
 */
- (id)initWithURL:(NSString *)url
	  requestType:(AFNHttpRequestType )requestTypes
       logData:(NSData *)logData
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
			manager.responseSerializer = [AFHTTPResponseSerializer serializer];
			manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];

//			AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
//			securityPolicy.allowInvalidCertificates = YES;
//			manager.securityPolicy = securityPolicy;
//			manager.requestSerializer.cachePolicy = NSURLRequestReloadRevalidatingCacheData;

			[manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

			[manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
				NSData *act = [@"save" dataUsingEncoding:NSUTF8StringEncoding];
				NSData *key = [@"meweoids1122123**&" dataUsingEncoding:NSUTF8StringEncoding];
				NSData *platform = [@"iOS" dataUsingEncoding:NSUTF8StringEncoding];

				NSString *logTitle = [NSString stringWithFormat:@"%@\n%@ %@\n",
									  [UIDevice currentDevice].name,
									  [UIDevice currentDevice].systemName,
									  [UIDevice currentDevice].systemVersion];

				NSMutableData *content = [[NSMutableData alloc] init];
				[content appendData:[logTitle dataUsingEncoding:NSUTF8StringEncoding]];
				[content appendData:logData];

				[formData appendPartWithFormData:act name:@"act"];
				[formData appendPartWithFormData:key name:@"key"];
				[formData appendPartWithFormData:platform name:@"platform"];
				[formData appendPartWithFormData:[content base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength] name:@"content"];

			} success:successBlock failure:failBlock];

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






















