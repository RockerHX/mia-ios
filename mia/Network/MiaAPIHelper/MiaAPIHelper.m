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


NSString *const TimtOutPrompt           = @"请求超时，请稍后重试";
NSString *const DataParseErrorPrompt    = @"数据解析出错，请联系Mia客服";
NSString *const UnknowErrorPrompt       = @"未知错误，请联系Mia客服";


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

+ (long)genTimestamp {
	long timestamp = (long)([[NSDate date] timeIntervalSince1970] * 1000000);
	long offset = (arc4random() % 1000);
	timestamp = (timestamp + offset);

	return timestamp;
}

+ (void)sendUUIDWithCompleteBlock:(MiaRequestCompleteBlock)completeBlock
					 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSString *currentUUID = [self getUUID];

	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:currentUUID forKey:MiaAPIKey_GUID];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_PostGuest
														  parameters:dictValues
													   completeBlock:completeBlock
														timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)getNearbyWithLatitude:(double)lat
                    longitude:(double)lon
                        start:(long)start
                         item:(long)item
                completeBlock:(MiaRequestCompleteBlock)completeBlock
                 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock
{
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:[NSNumber numberWithFloat:lat] forKey:MiaAPIKey_Latitude];
	[dictValues setValue:[NSNumber numberWithFloat:lon] forKey:MiaAPIKey_Longitude];
	//[dictValues setValue:[NSNumber numberWithLong:start] forKey:MiaAPIKey_Start];
	[dictValues setValue:[NSNumber numberWithLong:item] forKey:MiaAPIKey_Item];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_Music_GetNearby
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)getMusicCommentWithShareID:(NSString *)sID
							 start:(NSString *)start
							  item:(long)item
					 completeBlock:(MiaRequestCompleteBlock)completeBlock
						 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:sID forKey:MiaAPIKey_ID];
	[dictValues setValue:start forKey:MiaAPIKey_Start];
	[dictValues setValue:[NSNumber numberWithLong:item] forKey:MiaAPIKey_Item];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_Music_GetMcomm
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)getShareListWithUID:(NSString *)uID
					  start:(long)start
					   item:(long)item
			  completeBlock:(MiaRequestCompleteBlock)completeBlock
			   timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:uID forKey:MiaAPIKey_UID];
	[dictValues setValue:[NSNumber numberWithLong:start] forKey:MiaAPIKey_Start];
	[dictValues setValue:[NSNumber numberWithLong:item] forKey:MiaAPIKey_Item];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_Music_GetShlist
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)getInfectListWithSID:(NSString *)sID
					  startID:(NSString *)startID
					   item:(long)item
			  completeBlock:(MiaRequestCompleteBlock)completeBlock
			   timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:sID forKey:MiaAPIKey_sID];
	[dictValues setValue:startID forKey:MiaAPIKey_Start];
	[dictValues setValue:[NSNumber numberWithLong:item] forKey:MiaAPIKey_Item];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_Music_GetInfectList
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)getShareById:(NSString *)sID
				spID:(NSString *)spID
	   completeBlock:(MiaRequestCompleteBlock)completeBlock
		timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:sID forKey:MiaAPIKey_sID];
	if (![NSString isNull:spID]) {
		[dictValues setValue:spID forKey:MiaAPIKey_spID];
	}

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_Music_GetSharem
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)reportShareById:(NSString *)sID
	   completeBlock:(MiaRequestCompleteBlock)completeBlock
		timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:sID forKey:MiaAPIKey_sID];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_Music_PostReport
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)postReadCommentWithsID:(NSString *)sID
				 completeBlock:(MiaRequestCompleteBlock)completeBlock
				  timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:sID forKey:MiaAPIKey_sID];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_PostRcomm
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)getMusicById:(NSString *)mid
	   completeBlock:(MiaRequestCompleteBlock)completeBlock
		timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:mid forKey:MiaAPIKey_MID];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_Music_GetByid
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)getFavoriteListWithStart:(NSString *)start
							item:(long)item
				   completeBlock:(MiaRequestCompleteBlock)completeBlock
					timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:start forKey:MiaAPIKey_Start];
	[dictValues setValue:[NSNumber numberWithLong:item] forKey:MiaAPIKey_Item];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_GetStart
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)getUserInfoWithUID:(NSString *)uid
			 completeBlock:(MiaRequestCompleteBlock)completeBlock
					timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:uid forKey:MiaAPIKey_UID];
	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_GetUinfo
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)getUploadAvatarAuthWithCompleteBlock:(MiaRequestCompleteBlock)completeBlock
								timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_GetClogo
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)getUpdateInfoWithCompleteBlock:(MiaRequestCompleteBlock)completeBlock
								timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:@"ios" forKey:MiaAPIKey_Platform];
	[dictValues setValue:@"firim" forKey:MiaAPIKey_Channel];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_GetUpdate
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)getFansListWithUID:(NSString *)uID
					  start:(long)start
					   item:(long)item
			  completeBlock:(MiaRequestCompleteBlock)completeBlock
			   timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:uID forKey:MiaAPIKey_UID];
	[dictValues setValue:@"2" forKey:MiaAPIKey_Type];
	[dictValues setValue:[NSNumber numberWithLong:start] forKey:MiaAPIKey_Start];
	[dictValues setValue:[NSNumber numberWithLong:item] forKey:MiaAPIKey_Item];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_GetFriends
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)getFollowingListWithUID:(NSString *)uID
					 start:(long)start
					  item:(long)item
			 completeBlock:(MiaRequestCompleteBlock)completeBlock
			  timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:uID forKey:MiaAPIKey_UID];
	[dictValues setValue:@"1" forKey:MiaAPIKey_Type];
	[dictValues setValue:[NSNumber numberWithLong:start] forKey:MiaAPIKey_Start];
	[dictValues setValue:[NSNumber numberWithLong:item] forKey:MiaAPIKey_Item];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_GetFriends
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)searchUserWithKey:(NSString *)key
						  start:(long)start
						   item:(long)item
				  completeBlock:(MiaRequestCompleteBlock)completeBlock
				   timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:key forKey:MiaAPIKey_Key];
	[dictValues setValue:@"1" forKey:MiaAPIKey_Type];
	[dictValues setValue:[NSNumber numberWithLong:start] forKey:MiaAPIKey_Start];
	[dictValues setValue:[NSNumber numberWithLong:item] forKey:MiaAPIKey_Item];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_GetSuser
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)getNotifyWithLastID:(NSString *)notifyID
					 item:(long)item
			completeBlock:(MiaRequestCompleteBlock)completeBlock
			 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:notifyID forKey:MiaAPIKey_Start];
	[dictValues setValue:[NSNumber numberWithLong:item] forKey:MiaAPIKey_Item];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_GetNotify
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)InfectMusicWithLatitude:(double)lat
					  longitude:(double)lon
						address:(NSString *)address
						   spID:(NSString *)spID
				  completeBlock:(MiaRequestCompleteBlock)completeBlock
				   timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	if (![NSString isNull:address]) {
		[dictValues setValue:[NSNumber numberWithFloat:lat] forKey:MiaAPIKey_Latitude];
		[dictValues setValue:[NSNumber numberWithFloat:lon] forKey:MiaAPIKey_Longitude];
		[dictValues setValue:address forKey:MiaAPIKey_Address];
	}
	[dictValues setValue:spID forKey:MiaAPIKey_spID];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_PostInfectm
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)SkipMusicWithLatitude:(double)lat
					longitude:(double)lon
					  address:(NSString *)address
						 spID:(NSString *)spID
				completeBlock:(MiaRequestCompleteBlock)completeBlock
				 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	if (![NSString isNull:address]) {
		[dictValues setValue:[NSNumber numberWithFloat:lat] forKey:MiaAPIKey_Latitude];
		[dictValues setValue:[NSNumber numberWithFloat:lon] forKey:MiaAPIKey_Longitude];
		[dictValues setValue:address forKey:MiaAPIKey_Address];
	}
	[dictValues setValue:spID forKey:MiaAPIKey_spID];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_PostSkipm
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)viewShareWithLatitude:(double)lat
					longitude:(double)lon
					  address:(NSString *)address
						 spID:(NSString *)spID
				completeBlock:(MiaRequestCompleteBlock)completeBlock
				 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	if (![NSString isNull:address]) {
		[dictValues setValue:[NSNumber numberWithFloat:lat] forKey:MiaAPIKey_Latitude];
		[dictValues setValue:[NSNumber numberWithFloat:lon] forKey:MiaAPIKey_Longitude];
		[dictValues setValue:address forKey:MiaAPIKey_Address];
	}
	[dictValues setValue:spID forKey:MiaAPIKey_spID];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_PostViewm
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)favoriteMusicWithShareID:(NSString *)sID
					  isFavorite:(BOOL)isFavorite
				   completeBlock:(MiaRequestCompleteBlock)completeBlock
				 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:sID forKey:MiaAPIKey_ID];
	if (isFavorite) {
		// 期望的状态是已收藏，就添加收藏
		[dictValues setValue:[NSNumber numberWithLong:1] forKey:MiaAPIKey_Act];
	} else {
		[dictValues setValue:[NSNumber numberWithLong:0] forKey:MiaAPIKey_Act];
	}

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_PostFavorite
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)deleteFavoritesWithIDs:(NSArray *)idArray
				 completeBlock:(MiaRequestCompleteBlock)completeBlock
				  timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	// 拼接id字符串
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	NSMutableString *ids = [[NSMutableString alloc] init];
	for (NSString *item in idArray) {
		if (ids.length > 0) {
			[ids appendString:@","];
		}
		[ids appendString:item];
	}
	[dictValues setValue:ids forKey:MiaAPIKey_ID];

	[dictValues setValue:[NSNumber numberWithLong:0] forKey:MiaAPIKey_Act];
	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_PostFavorite
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)followWithUID:(NSString *)uID
					  isFollow:(BOOL)isFollow
				   completeBlock:(MiaRequestCompleteBlock)completeBlock
				 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:uID forKey:MiaAPIKey_UID];
	if (isFollow) {
		// 期望的状态是已收藏，就添加收藏
		[dictValues setValue:[NSNumber numberWithLong:1] forKey:MiaAPIKey_Type];
	} else {
		[dictValues setValue:[NSNumber numberWithLong:2] forKey:MiaAPIKey_Type];
	}

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_PostFollow
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)postCommentWithShareID:(NSString *)sID
					   comment:(NSString *)comment
					 commentID:(NSString *)commentID
				 completeBlock:(MiaRequestCompleteBlock)completeBlock
				  timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:sID forKey:MiaAPIKey_sID];
	[dictValues setValue:comment forKey:MiaAPIKey_Comm];
	if (![NSString isNull:commentID]) {
		[dictValues setValue:commentID forKey:MiaAPIKey_CommentID];
	}

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_PostComment
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)deleteShareById:(NSString *)sID
	   completeBlock:(MiaRequestCompleteBlock)completeBlock
		   timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:sID forKey:MiaAPIKey_sID];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_DeleteSharem
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)postShareWithLatitude:(double)lat
					longitude:(double)lon
					  address:(NSString *)address
					   songID:(NSString *)songID
						 note:(NSString *)note
				completeBlock:(MiaRequestCompleteBlock)completeBlock
				 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:[NSNumber numberWithFloat:lat] forKey:MiaAPIKey_Latitude];
	[dictValues setValue:[NSNumber numberWithFloat:lon] forKey:MiaAPIKey_Longitude];
	[dictValues setValue:address forKey:MiaAPIKey_Address];
	[dictValues setValue:songID forKey:MiaAPIKey_ID];
	[dictValues setValue:note forKey:MiaAPIKey_Note];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_PostShare
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)feedbackWithNote:(NSString *)note
						 contact:(NSString *)contact
				completeBlock:(MiaRequestCompleteBlock)completeBlock
				 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:note forKey:MiaAPIKey_Note];
	if (![NSString isNull:contact]) {
		[dictValues setValue:contact forKey:MiaAPIKey_Contact];
	}

	[dictValues setValue:[UIDevice currentDevice].systemName forKey:MiaAPIKey_Platform];
	[dictValues setValue:[UIDevice currentDevice].systemVersion forKey:MiaAPIKey_OSVersion];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_Feedback
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)notifyAfterUploadPicWithCompleteBlock:(MiaRequestCompleteBlock)completeBlock
					 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_PostPicture
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)getVerificationCodeWithType:(long)type
						phoneNumber:(NSString *)phoneNumber
					  completeBlock:(MiaRequestCompleteBlock)completeBlock
					   timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:[NSNumber numberWithLong:type] forKey:MiaAPIKey_Type];
	[dictValues setValue:phoneNumber forKey:MiaAPIKey_PhoneNumber];
	[dictValues setValue:MiaAPIDefaultIMEI forKey:MiaAPIKey_IMEI];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_PostPauth
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)registerWithPhoneNum:(NSString *)phoneNumber
					   scode:(NSString *)scode
					nickName:(NSString *)nickName
				passwordHash:(NSString *)passwordHash
			   completeBlock:(MiaRequestCompleteBlock)completeBlock
				timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:phoneNumber forKey:MiaAPIKey_PhoneNumber];
	[dictValues setValue:scode forKey:MiaAPIKey_SCode];
	[dictValues setValue:nickName forKey:MiaAPIKey_Nick];
	[dictValues setValue:passwordHash forKey:MiaAPIKey_Password];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_PostRegister
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)resetPasswordWithPhoneNum:(NSString *)phoneNumber
					 passwordHash:(NSString *)passwordHash
							scode:(NSString *)scode
					completeBlock:(MiaRequestCompleteBlock)completeBlock
					 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:phoneNumber forKey:MiaAPIKey_PhoneNumber];
	[dictValues setValue:[NSNumber numberWithLong:1] forKey:MiaAPIKey_Type];
	[dictValues setValue:scode forKey:MiaAPIKey_OldPwd];
	[dictValues setValue:passwordHash forKey:MiaAPIKey_NewPwd];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_PostChangePwd
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)changePasswordWithOldPasswordHash:(NSString *)oldPasswordHash
						  newPasswordHash:(NSString *)newPasswordHash
							completeBlock:(MiaRequestCompleteBlock)completeBlock
							 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:[NSNumber numberWithLong:0] forKey:MiaAPIKey_Type];
	[dictValues setValue:oldPasswordHash forKey:MiaAPIKey_OldPwd];
	[dictValues setValue:newPasswordHash forKey:MiaAPIKey_NewPwd];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_PostChangePwd
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)changeNickName:(NSString *)nick
		 completeBlock:(MiaRequestCompleteBlock)completeBlock
		  timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:nick forKey:MiaAPIKey_Nick];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_PostCnick
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)changeGender:(long)gender
	   completeBlock:(MiaRequestCompleteBlock)completeBlock
		timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:[NSNumber numberWithLong:gender] forKey:MiaAPIKey_Gender];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_PostGender
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)thirdLoginWithOpenID:(NSString *)openID
                     unionID:(NSString *)unionID
                       token:(NSString *)token
                    nickName:(NSString *)nickName
                         sex:(NSString *)sex
                        type:(NSString *)type
                      avatar:(NSString *)avatar
               completeBlock:(MiaRequestCompleteBlock)completeBlock
                timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
    NSMutableDictionary *dictValues = @{}.mutableCopy;
    [dictValues setValue:openID forKey:MiaAPIKey_OpenID];
    [dictValues setValue:unionID forKey:MiaAPIKey_UnionID];
    [dictValues setValue:token forKey:MiaAPIKey_Token];
    [dictValues setValue:nickName forKey:MiaAPIKey_NickName];
    [dictValues setValue:sex forKey:MiaAPIKey_Sex];
    [dictValues setValue:type forKey:MiaAPIKey_From];
    [dictValues setValue:avatar forKey:MiaAPIKey_HeadImageURL];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_PostThirdLogin
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)loginWithPhoneNum:(NSString *)phoneNumber
             passwordHash:(NSString *)passwordHash
            completeBlock:(MiaRequestCompleteBlock)completeBlock
             timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
    NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
    [dictValues setValue:phoneNumber forKey:MiaAPIKey_PhoneNumber];
    [dictValues setValue:[NSNumber numberWithLong:1] forKey:MiaAPIKey_Dev];
    [dictValues setValue:MiaAPIDefaultIMEI forKey:MiaAPIKey_IMEI];
    [dictValues setValue:passwordHash forKey:MiaAPIKey_Pwd];
    
    MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_PostLogin
                                                               parameters:dictValues
                                                            completeBlock:completeBlock
                                                             timeoutBlock:timeoutBlock];
    [[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)loginWithSession:(NSString *)uID
			 token:(NSString *)token
			completeBlock:(MiaRequestCompleteBlock)completeBlock
			 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	[dictValues setValue:uID forKey:MiaAPIKey_UID];
	[dictValues setValue:token forKey:MiaAPIKey_Token];

	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_PostSession
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}

+ (void)logoutWithCompleteBlock:(MiaRequestCompleteBlock)completeBlock
				   timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock {
	NSMutableDictionary *dictValues = [[NSMutableDictionary alloc] init];
	MiaRequestItem *requestItem = [[MiaRequestItem alloc] initWithCommand:MiaAPICommand_User_PostLogout
															   parameters:dictValues
															completeBlock:completeBlock
															 timeoutBlock:timeoutBlock];
	[[WebSocketMgr standard] sendWitRequestItem:requestItem];
}


@end
