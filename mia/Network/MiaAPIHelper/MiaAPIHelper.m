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
NSString * const MiaAPIKey_Return					= @"ret";

NSString * const MiaAPICommand_Music_GetNearby		= @"Music.Get.Nearby";
NSString * const MiaAPIKey_Latitude					= @"latitude";
NSString * const MiaAPIKey_Longitude				= @"longitude";
NSString * const MiaAPIKey_Start					= @"start";
NSString * const MiaAPIKey_Item						= @"item";

NSString * const MiaAPICommand_User_PostGuest		= @"User.Post.Guest";
NSString * const MiaAPIKey_GUID						= @"guid";

NSString * const UserDefaultsKey_UUID				= @"uuid";

@interface MiaAPIHelper()

@end

@implementation MiaAPIHelper{
}

+(id)getUUID {
	NSString *currentUUID = [UserDefaultsUtils valueWithKey:UserDefaultsKey_UUID];
	if (!currentUUID) {
		currentUUID = [[NSUUID UUID] UUIDString];
		[UserDefaultsUtils saveValue:currentUUID forKey:UserDefaultsKey_UUID];
	}

	return currentUUID;
}

+(void)sendUUID {
	NSString *currentUUID = [self getUUID];
	//NSLog(@"%@, %lu", currentUUID, (unsigned long)currentUUID.length);

	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	[dictionary setValue:MiaAPICommand_User_PostGuest forKey:MiaAPIKey_ClientCommand];
	[dictionary setValue:MiaAPIProtocolVersion forKey:MiaAPIKey_Version];
	NSString * timestamp = [NSString stringWithFormat:@"%ld",(long)([[NSDate date] timeIntervalSince1970] * 1000)];
	[dictionary setValue:timestamp forKey:MiaAPIKey_Timestamp];

	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:currentUUID forKey:MiaAPIKey_GUID];

	[dictionary setValue:dictValues forKey:MiaAPIKey_Values];

	NSError *error = nil;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
													   options:NSJSONWritingPrettyPrinted
														 error:&error];
	if (error) {
		NSLog(@"conver to json error: dic->%@", error);
		return;
	}

	NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	//NSLog(@"%@", jsonString);

	[[WebSocketMgr standard] send:jsonString];

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
		NSLog(@"conver to json error: dic->%@", error);
		return;
	}

	NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	NSLog(@"%@", jsonString);

	[[WebSocketMgr standard] send:jsonString];
}

@end
















