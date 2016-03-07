//
//  HXUserSession.m
//  mia
//
//  Created by miaios on 16/2/22.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXUserSession.h"
#import "NSString+MD5.h"
#import "MiaAPIHelper.h"
#import "PathHelper.h"

NSString *const kClearNotifyNotifacation = @"kClearNotifyNotifacation";

static NSString *UserFilePath = @"/user.data";

typedef void(^SuccessBlock)(HXUserSession *, NSString *);
typedef void(^FailureBlock)(NSString *);

@implementation HXUserSession {
    SuccessBlock _successBlock;
    FailureBlock _failureBlock;
}

#pragma mark - Singleton Methods
+ (instancetype)share {
    static HXUserSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        session = [[HXUserSession alloc] init];
    });
    return session;
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
    _user = [self unArchiveUser];
}

#pragma mark - Property
- (HXUserState)userState {
    return (_user.uid && _user.token);
}

- (NSString *)uid {
    return _user.uid;
}

- (BOOL)notify {
    return (_user.notifyCount > 0);
}

#pragma mark - Public Methods
- (void)loginWithSDKUser:(SSDKUser *)user success:(nullable void(^)(HXUserSession *, NSString *))success failure:(nullable void(^)(NSString *))failure {
    _successBlock = success;
    _failureBlock = failure;
    
    [self startWeiXinLoginRequestWithUser:user];
}

- (void)loginWithMobile:(NSString *)mobile password:(NSString *)password success:(nullable void(^)(HXUserSession *, NSString *))success failure:(nullable void(^)(NSString *))failure {
    _successBlock = success;
    _failureBlock = failure;
    
    [self startLoginRequestWithMobile:mobile password:password];
}

- (void)updateUser:(nonnull HXUserModel *)user {
    _user = user;
    [self archiveUser:user];
}

- (void)sysnc {
    [self updateUser:_user];
}

- (void)clearNotify {
    _user.notifyAvatar = nil;
    _user.notifyCount = 0;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kClearNotifyNotifacation object:nil];
}

- (void)logout {
    [self updateUser:[HXUserModel new]];
}

#pragma mark - Private Methods
- (void)archiveWithObject:(id)object filePath:(NSString *)filePath {
    NSString *path = [[PathHelper cacheDir] stringByAppendingString:filePath];
    [NSKeyedArchiver archiveRootObject:object toFile:path];
}

- (id)unArchiveWithFilePath:(NSString *)filePath {
    NSString *path = [[PathHelper cacheDir] stringByAppendingString:filePath];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}

- (HXUserModel *)archiveUserWithUserInfo:(NSDictionary *)userInfo {
    HXUserModel *user = [HXUserModel mj_objectWithKeyValues:userInfo];
    return [self archiveUser:user];
}

- (HXUserModel *)archiveUser:(HXUserModel *)user {
    [self archiveWithObject:user filePath:UserFilePath];
    return user;
}

- (HXUserModel *)unArchiveUser {
    return [self unArchiveWithFilePath:UserFilePath];
}

- (void)startWeiXinLoginRequestWithUser:(SSDKUser *)user {
    NSDictionary *credential = user.credential.rawData;
    NSString *openID = credential[@"openid"];
    NSString *unionID = credential[@"unionid"];
    NSString *token = user.credential.token;
    NSString *nickName = user.nickname;
    NSString *avatar = user.icon;
    NSString *sex = ((user.gender == SSDKGenderUnknown) ? @"0" : @(user.gender + 1).stringValue);

    [MiaAPIHelper thirdLoginWithOpenID:openID
                               unionID:unionID
                                 token:token
                              nickName:nickName
                                   sex:sex
                                  type:@"WEIXIN"
                                avatar:avatar
                         completeBlock:
     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
         if (success) {
             [self requestSuccessHandleData:userInfo[MiaAPIKey_Values]];
         } else {
             [self handelError:userInfo[MiaAPIKey_Values][MiaAPIKey_Error]];
         }
     } timeoutBlock:^(MiaRequestItem *requestItem) {
         [self requestTimeOut];
     }];
}

- (void)startLoginRequestWithMobile:(NSString *)mobile password:(NSString *)password {
    [MiaAPIHelper loginWithPhoneNum:mobile
                       passwordHash:[NSString md5HexDigest:password]
                      completeBlock:
     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
         if (success) {
             [self requestSuccessHandleData:userInfo[MiaAPIKey_Values]];
         } else {
             [self handelError:userInfo[MiaAPIKey_Values][MiaAPIKey_Error]];
         }
     } timeoutBlock:^(MiaRequestItem *requestItem) {
         [self requestTimeOut];
     }];
}

- (void)requestSuccessHandleData:(NSDictionary *)data {
    _user = [self archiveUserWithUserInfo:data];
    
    if (_user) {
        if (_successBlock) {
            _successBlock(self, @"登录成功");
        }
    } else {
        [self handelError:DataParseErrorPrompt];
    }
}

- (void)handelError:(NSString *)error {
    if (error.length) {
        if (_failureBlock) {
            _failureBlock(error);
        }
    } else {
        if (_failureBlock) {
            _failureBlock(UnknowErrorPrompt);
        }
    }
}

- (void)requestTimeOut {
    if (_failureBlock) {
        _failureBlock(TimtOutPrompt);
    }
}

@end
