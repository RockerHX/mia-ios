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
extern NSString * const MiaAPICommand_User_PostGuest;


@interface MiaAPIHelper : NSObject

+(id)getUUID;
+(void)sendUUID;
+(void)getNearbyWithLatitude:(float) lat longitude:(float) lon start:(long) start item:(long) item;

@end
