//
//  MiaAPIHelper.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

extern NSString * const MiaAPIKey_ServerCommand;
extern NSString * const MiaAPIKey_Values;
extern NSString * const MiaAPIKey_Return;

extern NSString * const MiaAPICommand_Music_GetNearby;
extern NSString * const MiaAPICommand_Music_GetMcomm;
extern NSString * const MiaAPICommand_User_PostGuest;
extern NSString * const MiaAPICommand_User_PostInfectm;
extern NSString * const MiaAPICommand_User_PostSkipm;
extern NSString * const MiaAPICommand_User_PostPauth;

@interface MiaAPIHelper : NSObject

+ (id)getUUID;
+ (void)sendUUID;
+ (void)getNearbyWithLatitude:(float)lat longitude:(float) lon start:(long) start item:(long) item;
+ (void)getMusicCommentWithShareID:(NSString *)sID start:(long) start item:(long) item;

+ (void)InfectMusicWithLatitude:(float)lat longitude:(float) lon address:(NSString *)address spID:(NSString *)spID;
+ (void)SkipMusicWithLatitude:(float)lat longitude:(float) lon address:(NSString *)address spID:(NSString *)spID;

+ (void)getVerificationCodeWithType:(long)type phoneNumber:(NSString *)phoneNumber;

@end
