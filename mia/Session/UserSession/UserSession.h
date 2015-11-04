//
//  UserSession.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

/*
 "{"C":"User.Post.Login","s":"1442905599693","v":{"ret":0,"uid":"291","nick":"eden","utype":"1","unreadCommCnt":"0"}}"
 */

typedef NS_ENUM(BOOL, UserSessionLoginState) {
    UserSessionLoginStateLogin = YES,
    UserSessionLoginStateLogout = NO
};

static NSString * const UserDefaultsKey_UserName            = @"name";
static NSString * const UserDefaultsKey_PasswordHash        = @"hash";
static NSString * const UserDefaultsKey_UID                 = @"uid";
static NSString * const UserDefaultsKey_Nick				= @"nick";

static NSString * const UserSessionKey_NickName				= @"nick";
static NSString * const UserSessionKey_Avatar				= @"avatar";
static NSString * const UserSessionKey_LoginState           = @"state";

@interface UserSession : NSObject

@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSString *nick;
@property (strong, nonatomic) NSString *avatar;
@property (strong, nonatomic) NSString *utype;
@property (strong, nonatomic) NSString *unreadCommCnt;

@property (nonatomic, assign) UserSessionLoginState state;

/**
 *  使用单例初始化
 *
 */
+ (instancetype)standard;

- (BOOL)isLogined;
- (BOOL)isCachedLogin;

- (void)logout;

@end
