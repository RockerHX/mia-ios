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

@interface UserSession()

@end

@implementation UserSession {
}

/**
 *  使用单例初始化
 *
 */
+ (id)standard{
    static UserSession *aUserSession = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        aUserSession = [[self alloc] init];
    });
    return aUserSession;
}

- (id)init {
	self = [super init];
	if (self) {
	}
	return self;
}

- (void)dealloc {
}

- (BOOL)isLogined {
	if (!_uid || _uid.length == 0)
		return NO;
	if (!_nick || _nick.length == 0)
		return NO;

	return YES;
}

- (void)logout {
	_uid = nil;
	_nick = nil;
	_utype = nil;
	_unreadCommCnt = nil;

	[UserDefaultsUtils removeObjectForKey:UserDefaultsKey_UserName];
	[UserDefaultsUtils removeObjectForKey:UserDefaultsKey_PasswordHash];
}
@end
















