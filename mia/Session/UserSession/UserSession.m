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

- (NSString *)uid {
    return [NSString stringWithFormat:@"%@", _uid];
}

#pragma mark - Public Methods
- (BOOL)isLogined {
    return self.state;
}

- (BOOL)isCachedLogin {
	NSString *session_uid = [UserDefaultsUtils valueWithKey:UserDefaultsKey_SessionUID];
	NSString *session_token = [UserDefaultsUtils valueWithKey:UserDefaultsKey_SessionToken];
	if ([NSString isNull:session_uid] || [NSString isNull:session_token]) {
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
	_notifyCnt = 0;
	_notifyUserpic = nil;
	self.avatar = nil;
	
	[UserDefaultsUtils removeObjectForKey:UserDefaultsKey_SessionUID];
	[UserDefaultsUtils removeObjectForKey:UserDefaultsKey_SessionToken];
    self.state = UserSessionLoginStateLogout;
}

- (void)clearNotify {
	[self setNotifyCnt:0];
	_notifyUserpic = nil;
}

- (void)saveAuthInfo:(NSString *)uid token:(NSString *)token {
    [UserDefaultsUtils saveValue:uid forKey:UserDefaultsKey_SessionUID];
    [UserDefaultsUtils saveValue:token forKey:UserDefaultsKey_SessionToken];
}

- (void)saveUserInfoUid:(NSString *)uid nickName:(NSString *)nickName {
    [UserDefaultsUtils saveValue:uid forKey:UserDefaultsKey_UID];
    [UserDefaultsUtils saveValue:nickName forKey:UserDefaultsKey_Nick];
}

@end
