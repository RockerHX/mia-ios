//
//  MiaAPIHelper.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//
//

#import "MiaAPIHelper.h"
#import "WebSocketMgr.h"
#import "UserDefaultsUtils.h"

NSString * const MiaAPIProtocolVersion				= @"1";

NSString * const MiaAPIKey_ServerCommand			= @"C";
NSString * const MiaAPIKey_ClientCommand			= @"c";
NSString * const MiaAPIKey_Version					= @"r";
NSString * const MiaAPIKey_Timestamp				= @"s";
NSString * const MiaAPIKey_Values					= @"v";

NSString * const MiaAPICommand_Music_GetNearby		= @"Music.Get.Nearby";

NSString * const MiaAPIKey_Latitude					= @"latitude";
NSString * const MiaAPIKey_Longitude				= @"longitude";
NSString * const MiaAPIKey_Start					= @"start";
NSString * const MiaAPIKey_Item						= @"item";

NSString * const UserDefaultsKey_GUID				= @"guid";

@interface MiaAPIHelper()

@end

@implementation MiaAPIHelper{
}

+(void)sendGUID {
	NSString *currentGUID = [UserDefaultsUtils valueWithKey:UserDefaultsKey_GUID];
	if (!currentGUID) {
		currentGUID = [[NSUUID UUID] UUIDString];
		[UserDefaultsUtils saveValue:currentGUID forKey:UserDefaultsKey_GUID];
	}

	//NSLog(@"%@, %d", currentGUID, currentGUID.length);
	// TODO send to server
}

+(void)getNearbyWithLatitude:(float) lat longitude:(float) lon start:(long) start item:(long) item {
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	[dictionary setValue:MiaAPICommand_Music_GetNearby forKey:MiaAPIKey_ClientCommand];
    [dictionary setValue:MiaAPIProtocolVersion forKey:MiaAPIKey_Version];
	NSString * timestamp = [NSString stringWithFormat:@"%ld",(long)([[NSDate date] timeIntervalSince1970] * 1000)];
	[dictionary setValue:timestamp forKey:MiaAPIKey_Timestamp];

	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:[NSNumber numberWithFloat:lat] forKey:MiaAPIKey_Latitude];
	[dictValues setValue:[NSNumber numberWithFloat:lon] forKey:MiaAPIKey_Longitude];
	[dictValues setValue:[NSNumber numberWithLong:start] forKey:MiaAPIKey_Start];
	[dictValues setValue:[NSNumber numberWithLong:item] forKey:MiaAPIKey_Item];

	[dictionary setValue:dictValues forKey:MiaAPIKey_Values];

	NSError *error = nil;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
													   options:NSJSONWritingPrettyPrinted
														 error:&error];
	if (error) {
		NSLog(@"dic->%@", error);
	}

	NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	NSLog(@"%@", jsonString);

	[[WebSocketMgr standarWebSocketMgr] send:jsonString];
}

@end
















