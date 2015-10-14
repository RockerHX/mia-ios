//
//  UserSetting.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

extern NSString * const UserDefaultsKey_PlayWith3G;
extern NSString * const UserDefaultsKey_AutoPlay;


@interface UserSetting : NSObject

+ (BOOL)playWith3G;
+ (void)setPlayWith3G:(BOOL)value;

+ (BOOL)autoPlay;
+ (void)setAutoPlay:(BOOL)value;

+ (BOOL)isAllowedToPlayNow;

@end
