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

+ (void)getNearbyWithLatitude:(double)lat
					longitude:(double)lon
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

+ (void)getInfectListWithSID:(NSString *)sID
					 startID:(NSString *)startID
						item:(long)item
			   completeBlock:(MiaRequestCompleteBlock)completeBlock
				timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)getShareById:(NSString *)sID
	   completeBlock:(MiaRequestCompleteBlock)completeBlock
		timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)reportShareById:(NSString *)sID
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

+ (void)getUpdateInfoWithCompleteBlock:(MiaRequestCompleteBlock)completeBlock
								timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)InfectMusicWithLatitude:(double)lat
					  longitude:(double)lon
						address:(NSString *)address
						   spID:(NSString *)spID
				  completeBlock:(MiaRequestCompleteBlock)completeBlock
				   timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)SkipMusicWithLatitude:(double)lat
					longitude:(double)lon
					  address:(NSString *)address
						 spID:(NSString *)spID
				completeBlock:(MiaRequestCompleteBlock)completeBlock
				 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)viewShareWithLatitude:(double)lat
					longitude:(double)lon
					  address:(NSString *)address
						 spID:(NSString *)spID
				completeBlock:(MiaRequestCompleteBlock)completeBlock
				 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

/**
 * @param isFavorite 期望设置成的收藏状态
 */
+ (void)favoriteMusicWithShareID:(NSString *)sID
					  isFavorite:(BOOL)isFavorite
				   completeBlock:(MiaRequestCompleteBlock)completeBlock
				 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)deleteFavoritesWithIDs:(NSArray *)idArray
				 completeBlock:(MiaRequestCompleteBlock)completeBlock
				  timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)postCommentWithShareID:(NSString *)sID
					   comment:(NSString *)comment
				 completeBlock:(MiaRequestCompleteBlock)completeBlock
				  timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)postShareWithLatitude:(double)lat
					longitude:(double)lon
					  address:(NSString *)address
					   songID:(NSString *)songID
						 note:(NSString *)note
				completeBlock:(MiaRequestCompleteBlock)completeBlock
				 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)deleteShareById:(NSString *)sID
	   completeBlock:(MiaRequestCompleteBlock)completeBlock
		   timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)feedbackWithNote:(NSString *)note
				 contact:(NSString *)contact
		   completeBlock:(MiaRequestCompleteBlock)completeBlock
			timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)notifyAfterUploadPicWithCompleteBlock:(MiaRequestCompleteBlock)completeBlock
								 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)getVerificationCodeWithType:(long)type
						phoneNumber:(NSString *)phoneNumber
					  completeBlock:(MiaRequestCompleteBlock)completeBlock
					   timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)registerWithPhoneNum:(NSString *)phoneNumber
					   scode:(NSString *)scode
					nickName:(NSString *)nickName
				passwordHash:(NSString *)passwordHash
			   completeBlock:(MiaRequestCompleteBlock)completeBlock
				timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)resetPasswordWithPhoneNum:(NSString *)phoneNumber
					 passwordHash:(NSString *)passwordHash
							scode:(NSString *)scode
					completeBlock:(MiaRequestCompleteBlock)completeBlock
					 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)changePasswordWithOldPasswordHash:(NSString *)oldPasswordHash
					 newPasswordHash:(NSString *)newPasswordHash
					completeBlock:(MiaRequestCompleteBlock)completeBlock
					 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)changeNickName:(NSString *)nick
		 completeBlock:(MiaRequestCompleteBlock)completeBlock
		  timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)changeGender:(long)gender
	   completeBlock:(MiaRequestCompleteBlock)completeBlock
		timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)loginWithPhoneNum:(NSString *)phoneNumber
			 passwordHash:(NSString *)passwordHash
			completeBlock:(MiaRequestCompleteBlock)completeBlock
			 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)loginWithPassport:(NSString *)token
				 nickname:(NSString *)nickname
					  sex:(long)sex
					 from:(NSString *)from
			   headImgUrl:(NSString *)headImgUrl
			completeBlock:(MiaRequestCompleteBlock)completeBlock
			 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)logoutWithCompleteBlock:(MiaRequestCompleteBlock)completeBlock
				   timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

@end
