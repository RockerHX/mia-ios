//
//  UserSetting.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//
//

#import "UserSetting.h"
#import "UserDefaultsUtils.h"
#import "WebSocketMgr.h"

NSString * const UserDefaultsKey_PlayWith3G			= @"PlayWith3G";
NSString * const UserDefaultsKey_AutoPlay			= @"AutoPlay";

@interface UserSetting()

@end

@implementation UserSetting {
}

+ (BOOL)playWith3G {
	return [UserDefaultsUtils boolValueWithKey:UserDefaultsKey_PlayWith3G];
}

+ (void)setPlayWith3G:(BOOL)value {
	[UserDefaultsUtils saveBoolValue:value withKey:UserDefaultsKey_PlayWith3G];
}

+ (BOOL)autoPlay {
	return [UserDefaultsUtils boolValueWithKey:UserDefaultsKey_AutoPlay];
}

+ (void)setAutoPlay:(BOOL)value {
	[UserDefaultsUtils saveBoolValue:value withKey:UserDefaultsKey_AutoPlay];
}

+ (BOOL)isAllowedToPlayNowWithURL:(NSString *)url {
	static NSString * const kLocalFilePrefix = @"file://";
	
	if ([self playWith3G]) {
		return YES;
	}

	if ([[WebSocketMgr standard] isWifiNetwork]) {
		return YES;
	}

	if ([url hasPrefix:kLocalFilePrefix]) {
		return YES;
	}

	return NO;
}

@end
















