//
//  MiaAPIHelper.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "MiaAPIMacro.h"
#import "MiaRequestItem.h"

@interface MiaAPIHelper : NSObject

+ (id)getUUID;
+ (void)sendUUIDWithCompleteBlock:(MiaRequestCompleteBlock)completeBlock
					 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)getNearbyWithLatitude:(float)lat
					longitude:(float)lon
						start:(long)start
						 item:(long)item
				 completeBlock:(MiaRequestCompleteBlock)completeBlock
				 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)getMusicCommentWithShareID:(NSString *)sID
							 start:(NSString *)start
							  item:(long)item
					 completeBlock:(MiaRequestCompleteBlock)completeBlock
						 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)getShareListWithUID:(NSString *)uID
					  start:(long)start
					   item:(long)item
			  completeBlock:(MiaRequestCompleteBlock)completeBlock
			   timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)getShareById:(NSString *)sID
	   completeBlock:(MiaRequestCompleteBlock)completeBlock
		timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)postReadCommentWithsID:(NSString *)sID
				 completeBlock:(MiaRequestCompleteBlock)completeBlock
				  timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)getMusicById:(NSString *)mid
	   completeBlock:(MiaRequestCompleteBlock)completeBlock
		timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)getFavoriteListWithStart:(NSString *)start
							item:(long)item
				   completeBlock:(MiaRequestCompleteBlock)completeBlock
					timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)getUserInfoWithUID:(NSString *)uid
			 completeBlock:(MiaRequestCompleteBlock)completeBlock
					timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)getUploadAvatarAuthWithCompleteBlock:(MiaRequestCompleteBlock)completeBlock
								timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)InfectMusicWithLatitude:(float)lat longitude:(float) lon address:(NSString *)address spID:(NSString *)spID;
+ (void)SkipMusicWithLatitude:(float)lat longitude:(float) lon address:(NSString *)address spID:(NSString *)spID;
+ (void)viewShareWithLatitude:(float)lat longitude:(float) lon address:(NSString *)address spID:(NSString *)spID;

+ (void)getVerificationCodeWithType:(long)type phoneNumber:(NSString *)phoneNumber;
+ (void)registerWithPhoneNum:(NSString *)phoneNumber scode:(NSString *)scode nickName:(NSString *)nickName passwordHash:(NSString *)passwordHash;
+ (void)resetPasswordWithPhoneNum:(NSString *)phoneNumber passwordHash:(NSString *)passwordHash scode:(NSString *)scode;

+ (void)changeNickName:(NSString *)nick;
+ (void)changeGender:(long)gender;

+ (void)loginWithPhoneNum:(NSString *)phoneNumber passwordHash:(NSString *)passwordHash;
+ (void)logout;

/**
* @param isFavorite 期望设置成的收藏状态
*/
+ (void)favoriteMusicWithShareID:(NSString *)sID isFavorite:(BOOL)isFavorite;
+ (void)deleteFavoritesWithIDs:(NSArray *)idArray;

+ (void)postCommentWithShareID:(NSString *)sID comment:(NSString *)comment;

+ (void)postShareWithLatitude:(float)lat
					longitude:(float)lon
					  address:(NSString *)address
					   songID:(NSString *)songID
						 note:(NSString *)note;

@end
