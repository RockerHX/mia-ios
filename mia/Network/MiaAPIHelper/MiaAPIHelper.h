//
//  MiaAPIHelper.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "MiaAPIMacro.h"

@interface MiaAPIHelper : NSObject

+ (id)getUUID;
+ (void)sendUUID;
+ (void)getNearbyWithLatitude:(float)lat longitude:(float) lon start:(long) start item:(long) item;
+ (void)getMusicCommentWithShareID:(NSString *)sID start:(long) start item:(long) item;
+ (void)getShareListWithUID:(NSString *)uID start:(long) start item:(long) item;

+ (void)InfectMusicWithLatitude:(float)lat longitude:(float) lon address:(NSString *)address spID:(NSString *)spID;
+ (void)SkipMusicWithLatitude:(float)lat longitude:(float) lon address:(NSString *)address spID:(NSString *)spID;

+ (void)getVerificationCodeWithType:(long)type phoneNumber:(NSString *)phoneNumber;
+ (void)registerWithPhoneNum:(NSString *)phoneNumber scode:(NSString *)scode nickName:(NSString *)nickName passwordHash:(NSString *)passwordHash;
+ (void)resetPasswordWithPhoneNum:(NSString *)phoneNumber passwordHash:(NSString *)passwordHash scode:(NSString *)scode;
+ (void)loginWithPhoneNum:(NSString *)phoneNumber passwordHash:(NSString *)passwordHash;

/**
* @param isFavorite 期望设置成的收藏状态
*/
+ (void)favoriteMusicWithShareID:(NSString *)sID isFavorite:(BOOL)isFavorite;

@end
