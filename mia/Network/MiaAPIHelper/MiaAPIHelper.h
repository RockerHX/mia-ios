//
//  MiaAPIHelper.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

extern NSString * const MiaAPIKey_ServerCommand;

@interface MiaAPIHelper : NSObject

+(void)sendGUID;
+(void)getNearbyWithLatitude:(float) lat longitude:(float) lon start:(long) start item:(long) item;

@end
