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
#import "NSString+IsNull.h"

@interface MiaAPIHelper()

@end

@implementation MiaAPIHelper{
}

+ (id)getUUID {
	static NSString * const UserDefaultsKey_UUID = @"uuid";
	NSString *currentUUID = [UserDefaultsUtils valueWithKey:UserDefaultsKey_UUID];
	if (!currentUUID) {
		currentUUID = [[NSUUID UUID] UUIDString];
		[UserDefaultsUtils saveValue:currentUUID forKey:UserDefaultsKey_UUID];
	}

	return currentUUID;
}

+ (void)sendUUID {
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

+ (void)getNearbyWithLatitude:(float) lat longitude:(float) lon start:(long) start item:(long) item {
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	[dictionary setValue:MiaAPICommand_Music_GetNearby forKey:MiaAPIKey_ClientCommand];
    [dictionary setValue:MiaAPIProtocolVersion forKey:MiaAPIKey_Version];
	NSString * timestamp = [NSString stringWithFormat:@"%ld",(long)([[NSDate date] timeIntervalSince1970] * 1000)];
	[dictionary setValue:timestamp forKey:MiaAPIKey_Timestamp];

	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:[NSNumber numberWithFloat:lat] forKey:MiaAPIKey_Latitude];
	[dictValues setValue:[NSNumber numberWithFloat:lon] forKey:MiaAPIKey_Longitude];
	//[dictValues setValue:[NSNumber numberWithLong:start] forKey:MiaAPIKey_Start];
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
	//NSLog(@"%@", jsonString);

	[[WebSocketMgr standard] send:jsonString];
}

+ (void)getMusicCommentWithShareID:(NSString *)sID start:(NSString *) start item:(long) item {
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	[dictionary setValue:MiaAPICommand_Music_GetMcomm forKey:MiaAPIKey_ClientCommand];
	[dictionary setValue:MiaAPIProtocolVersion forKey:MiaAPIKey_Version];
	NSString * timestamp = [NSString stringWithFormat:@"%ld",(long)([[NSDate date] timeIntervalSince1970] * 1000)];
	[dictionary setValue:timestamp forKey:MiaAPIKey_Timestamp];

	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:sID forKey:MiaAPIKey_ID];
	[dictValues setValue:start forKey:MiaAPIKey_Start];
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
	//NSLog(@"%@", jsonString);

	[[WebSocketMgr standard] send:jsonString];
}

+ (void)getShareListWithUID:(NSString *)uID start:(long) start item:(long) item {
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	[dictionary setValue:MiaAPICommand_Music_GetShlist forKey:MiaAPIKey_ClientCommand];
	[dictionary setValue:MiaAPIProtocolVersion forKey:MiaAPIKey_Version];
	NSString * timestamp = [NSString stringWithFormat:@"%ld",(long)([[NSDate date] timeIntervalSince1970] * 1000)];
	[dictionary setValue:timestamp forKey:MiaAPIKey_Timestamp];

	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:uID forKey:MiaAPIKey_UID];
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
	//NSLog(@"%@", jsonString);

	[[WebSocketMgr standard] send:jsonString];
}

+ (void)getShareById:(NSString *)sID {
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	[dictionary setValue:MiaAPICommand_Music_GetSharem forKey:MiaAPIKey_ClientCommand];
	[dictionary setValue:MiaAPIProtocolVersion forKey:MiaAPIKey_Version];
	NSString * timestamp = [NSString stringWithFormat:@"%ld",(long)([[NSDate date] timeIntervalSince1970] * 1000)];
	[dictionary setValue:timestamp forKey:MiaAPIKey_Timestamp];

	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:sID forKey:MiaAPIKey_sID];

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

+ (void)getMusicById:(NSString *)mid {
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	[dictionary setValue:MiaAPICommand_Music_GetByid forKey:MiaAPIKey_ClientCommand];
	[dictionary setValue:MiaAPIProtocolVersion forKey:MiaAPIKey_Version];
	NSString * timestamp = [NSString stringWithFormat:@"%ld",(long)([[NSDate date] timeIntervalSince1970] * 1000)];
	[dictionary setValue:timestamp forKey:MiaAPIKey_Timestamp];

	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:mid forKey:MiaAPIKey_MID];

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

+ (void)getFavoriteListWithStart:(NSString *) start item:(long) item {
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	[dictionary setValue:MiaAPICommand_User_GetStart forKey:MiaAPIKey_ClientCommand];
	[dictionary setValue:MiaAPIProtocolVersion forKey:MiaAPIKey_Version];
	NSString * timestamp = [NSString stringWithFormat:@"%ld",(long)([[NSDate date] timeIntervalSince1970] * 1000)];
	[dictionary setValue:timestamp forKey:MiaAPIKey_Timestamp];

	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:start forKey:MiaAPIKey_Start];
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
	//NSLog(@"%@", jsonString);

	[[WebSocketMgr standard] send:jsonString];
}

+ (void)InfectMusicWithLatitude:(float)lat longitude:(float) lon address:(NSString *)address spID:(NSString *)spID {
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	[dictionary setValue:MiaAPICommand_User_PostInfectm forKey:MiaAPIKey_ClientCommand];
	[dictionary setValue:MiaAPIProtocolVersion forKey:MiaAPIKey_Version];
	NSString * timestamp = [NSString stringWithFormat:@"%ld",(long)([[NSDate date] timeIntervalSince1970] * 1000)];
	[dictionary setValue:timestamp forKey:MiaAPIKey_Timestamp];

	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	if (![NSString isNull:address]) {
		[dictValues setValue:[NSNumber numberWithFloat:lat] forKey:MiaAPIKey_Latitude];
		[dictValues setValue:[NSNumber numberWithFloat:lon] forKey:MiaAPIKey_Longitude];
		[dictValues setValue:address forKey:MiaAPIKey_Address];
	}
	[dictValues setValue:spID forKey:MiaAPIKey_spID];

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

+ (void)SkipMusicWithLatitude:(float)lat longitude:(float) lon address:(NSString *)address spID:(NSString *)spID {
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	[dictionary setValue:MiaAPICommand_User_PostSkipm forKey:MiaAPIKey_ClientCommand];
	[dictionary setValue:MiaAPIProtocolVersion forKey:MiaAPIKey_Version];
	NSString * timestamp = [NSString stringWithFormat:@"%ld",(long)([[NSDate date] timeIntervalSince1970] * 1000)];
	[dictionary setValue:timestamp forKey:MiaAPIKey_Timestamp];

	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	if (![NSString isNull:address]) {
		[dictValues setValue:[NSNumber numberWithFloat:lat] forKey:MiaAPIKey_Latitude];
		[dictValues setValue:[NSNumber numberWithFloat:lon] forKey:MiaAPIKey_Longitude];
		[dictValues setValue:address forKey:MiaAPIKey_Address];
	}
	[dictValues setValue:spID forKey:MiaAPIKey_spID];

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

+ (void)viewShareWithLatitude:(float)lat longitude:(float) lon address:(NSString *)address spID:(NSString *)spID {
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	[dictionary setValue:MiaAPICommand_User_PostViewm forKey:MiaAPIKey_ClientCommand];
	[dictionary setValue:MiaAPIProtocolVersion forKey:MiaAPIKey_Version];
	NSString * timestamp = [NSString stringWithFormat:@"%ld",(long)([[NSDate date] timeIntervalSince1970] * 1000)];
	[dictionary setValue:timestamp forKey:MiaAPIKey_Timestamp];

	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	if (![NSString isNull:address]) {
		[dictValues setValue:[NSNumber numberWithFloat:lat] forKey:MiaAPIKey_Latitude];
		[dictValues setValue:[NSNumber numberWithFloat:lon] forKey:MiaAPIKey_Longitude];
		[dictValues setValue:address forKey:MiaAPIKey_Address];
	}
	[dictValues setValue:spID forKey:MiaAPIKey_spID];

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

+ (void)getVerificationCodeWithType:(long)type phoneNumber:(NSString *)phoneNumber {
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	[dictionary setValue:MiaAPICommand_User_PostPauth forKey:MiaAPIKey_ClientCommand];
	[dictionary setValue:MiaAPIProtocolVersion forKey:MiaAPIKey_Version];
	NSString * timestamp = [NSString stringWithFormat:@"%ld",(long)([[NSDate date] timeIntervalSince1970] * 1000)];
	[dictionary setValue:timestamp forKey:MiaAPIKey_Timestamp];

	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:[NSNumber numberWithLong:type] forKey:MiaAPIKey_Type];
	[dictValues setValue:phoneNumber forKey:MiaAPIKey_PhoneNumber];
	[dictValues setValue:MiaAPIDefaultIMEI forKey:MiaAPIKey_IMEI];

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

+ (void)registerWithPhoneNum:(NSString *)phoneNumber scode:(NSString *)scode nickName:(NSString *)nickName passwordHash:(NSString *)passwordHash {
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	[dictionary setValue:MiaAPICommand_User_PostRegister forKey:MiaAPIKey_ClientCommand];
	[dictionary setValue:MiaAPIProtocolVersion forKey:MiaAPIKey_Version];
	NSString * timestamp = [NSString stringWithFormat:@"%ld",(long)([[NSDate date] timeIntervalSince1970] * 1000)];
	[dictionary setValue:timestamp forKey:MiaAPIKey_Timestamp];

	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:phoneNumber forKey:MiaAPIKey_PhoneNumber];
	[dictValues setValue:scode forKey:MiaAPIKey_SCode];
	[dictValues setValue:nickName forKey:MiaAPIKey_NickName];
	[dictValues setValue:passwordHash forKey:MiaAPIKey_Password];

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

+ (void)resetPasswordWithPhoneNum:(NSString *)phoneNumber passwordHash:(NSString *)passwordHash scode:(NSString *)scode {
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	[dictionary setValue:MiaAPICommand_User_PostChangePwd forKey:MiaAPIKey_ClientCommand];
	[dictionary setValue:MiaAPIProtocolVersion forKey:MiaAPIKey_Version];
	NSString * timestamp = [NSString stringWithFormat:@"%ld",(long)([[NSDate date] timeIntervalSince1970] * 1000)];
	[dictionary setValue:timestamp forKey:MiaAPIKey_Timestamp];

	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:phoneNumber forKey:MiaAPIKey_PhoneNumber];
	[dictValues setValue:[NSNumber numberWithLong:1] forKey:MiaAPIKey_Type];
	[dictValues setValue:scode forKey:MiaAPIKey_OldPwd];
	[dictValues setValue:passwordHash forKey:MiaAPIKey_NewPwd];

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

+ (void)loginWithPhoneNum:(NSString *)phoneNumber passwordHash:(NSString *)passwordHash {
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	[dictionary setValue:MiaAPICommand_User_PostLogin forKey:MiaAPIKey_ClientCommand];
	[dictionary setValue:MiaAPIProtocolVersion forKey:MiaAPIKey_Version];
	NSString * timestamp = [NSString stringWithFormat:@"%ld",(long)([[NSDate date] timeIntervalSince1970] * 1000)];
	[dictionary setValue:timestamp forKey:MiaAPIKey_Timestamp];

	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:phoneNumber forKey:MiaAPIKey_PhoneNumber];
	[dictValues setValue:[NSNumber numberWithLong:1] forKey:MiaAPIKey_Dev];
	[dictValues setValue:MiaAPIDefaultIMEI forKey:MiaAPIKey_IMEI];
	[dictValues setValue:passwordHash forKey:MiaAPIKey_Pwd];

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

+ (void)logout {
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	[dictionary setValue:MiaAPICommand_User_PostLogout forKey:MiaAPIKey_ClientCommand];
	[dictionary setValue:MiaAPIProtocolVersion forKey:MiaAPIKey_Version];
	NSString * timestamp = [NSString stringWithFormat:@"%ld",(long)([[NSDate date] timeIntervalSince1970] * 1000)];
	[dictionary setValue:timestamp forKey:MiaAPIKey_Timestamp];

	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
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

+ (void)favoriteMusicWithShareID:(NSString *)sID isFavorite:(BOOL)isFavorite {
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	[dictionary setValue:MiaAPICommand_User_PostFavorite forKey:MiaAPIKey_ClientCommand];
	[dictionary setValue:MiaAPIProtocolVersion forKey:MiaAPIKey_Version];
	NSString * timestamp = [NSString stringWithFormat:@"%ld",(long)([[NSDate date] timeIntervalSince1970] * 1000)];
	[dictionary setValue:timestamp forKey:MiaAPIKey_Timestamp];

	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:sID forKey:MiaAPIKey_ID];
	if (isFavorite) {
		// 期望的状态是已收藏，就添加收藏
		[dictValues setValue:[NSNumber numberWithLong:1] forKey:MiaAPIKey_Act];
	} else {
		[dictValues setValue:[NSNumber numberWithLong:0] forKey:MiaAPIKey_Act];
	}

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

+ (void)postCommentWithShareID:(NSString *)sID comment:(NSString *)comment {
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	[dictionary setValue:MiaAPICommand_User_PostComment forKey:MiaAPIKey_ClientCommand];
	[dictionary setValue:MiaAPIProtocolVersion forKey:MiaAPIKey_Version];
	NSString * timestamp = [NSString stringWithFormat:@"%ld",(long)([[NSDate date] timeIntervalSince1970] * 1000)];
	[dictionary setValue:timestamp forKey:MiaAPIKey_Timestamp];

	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:sID forKey:MiaAPIKey_sID];
	[dictValues setValue:comment forKey:MiaAPIKey_Comm];

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

+ (void)postShareWithLatitude:(float)lat
					longitude:(float)lon
					  address:(NSString *)address
					   songID:(NSString *)songID
						 note:(NSString *)note {
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	[dictionary setValue:MiaAPICommand_User_PostShare forKey:MiaAPIKey_ClientCommand];
	[dictionary setValue:MiaAPIProtocolVersion forKey:MiaAPIKey_Version];
	NSString * timestamp = [NSString stringWithFormat:@"%ld",(long)([[NSDate date] timeIntervalSince1970] * 1000)];
	[dictionary setValue:timestamp forKey:MiaAPIKey_Timestamp];

	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:[NSNumber numberWithFloat:lat] forKey:MiaAPIKey_Latitude];
	[dictValues setValue:[NSNumber numberWithFloat:lon] forKey:MiaAPIKey_Longitude];
	[dictValues setValue:address forKey:MiaAPIKey_Address];
	[dictValues setValue:songID forKey:MiaAPIKey_ID];
	[dictValues setValue:note forKey:MiaAPIKey_Note];

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

@end
















