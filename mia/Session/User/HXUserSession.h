//
//  HXUserSession.h
//  mia
//
//  Created by miaios on 16/2/22.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <ShareSDK/ShareSDK.h>
#import "HXUserModel.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const kClearNotifyNotifacation;

typedef NS_ENUM(BOOL, HXUserState) {
    HXUserStateLogout,
    HXUserStateLogin
};

@interface HXUserSession : NSObject

@property (nonatomic, assign, readonly) HXUserState  userState;
@property (nonatomic, strong, readonly) HXUserModel *user;
@property (nonatomic, strong, readonly)    NSString *uid;

@property (nonatomic, assign, readonly) BOOL  notify;


+ (instancetype)share;

- (void)loginWithSDKUser:(SSDKUser *)user
                 success:(nullable void(^)(HXUserSession *session, NSString *prompt))success
                 failure:(nullable void(^)(NSString *prompt))failure;

- (void)loginWithMobile:(NSString *)mobile
               password:(NSString *)password
                success:(nullable void(^)(HXUserSession *session, NSString *prompt))success
                failure:(nullable void(^)(NSString *prompt))failure;

- (void)updateUser:(HXUserModel *)user;
- (void)sysnc;
- (void)clearNotify;

- (void)logout;

@end

NS_ASSUME_NONNULL_END