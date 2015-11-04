//
//  UserSession.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//
//

#import "UserSession.h"
#import "UserDefaultsUtils.h"
#import "NSString+IsNull.h"

@interface UserSession()

@end

@implementation UserSession {
}

#pragma mark - Class Methods
/**
 *  使用单例初始化
 *
 */
+ (instancetype)standard{
    static UserSession *aUserSession = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        aUserSession = [[self alloc] init];
    });
    return aUserSession;
}

#pragma mark - Init Methods
- (instancetype)init {
	self = [super init];
	if (self) {
		_uid = [UserDefaultsUtils valueWithKey:UserDefaultsKey_UID];
		_nick = [UserDefaultsUtils valueWithKey:UserDefaultsKey_Nick];
	}
	return self;
}

#pragma mark - Setter And Getter
- (UserSessionLoginState)state {
    // 为了和无网络时的缓存登录区分开，加了utype的判断
    if ([NSString isNull:_utype]) {
        return UserSessionLoginStateLogout;
    }
    if ([NSString isNull:_uid]) {
        return UserSessionLoginStateLogout;
    }
    if ([NSString isNull:_nick]) {
        return UserSessionLoginStateLogout;
    }
    
    return UserSessionLoginStateLogin;
}

#pragma mark - Public Methods
- (BOOL)isLogined {
    return self.state;
}

- (BOOL)isCachedLogin {
	NSString *userName = [UserDefaultsUtils valueWithKey:UserDefaultsKey_UserName];
	NSString *passwordHash = [UserDefaultsUtils valueWithKey:UserDefaultsKey_PasswordHash];
	if ([NSString isNull:userName] || [NSString isNull:passwordHash]) {
		return NO;
	}
    
	if ([NSString isNull:_uid] || [NSString isNull:_nick]) {
		return NO;
	}
    
	return YES;
}

- (void)logout {
	_uid = nil;
	self.nick = nil;
	_utype = nil;
	_unreadCommCnt = nil;
	self.avatar = nil;
	
	[UserDefaultsUtils removeObjectForKey:UserDefaultsKey_UserName];
	[UserDefaultsUtils removeObjectForKey:UserDefaultsKey_PasswordHash];
    self.state = UserSessionLoginStateLogout;
}

@end
