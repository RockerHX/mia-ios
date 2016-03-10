//
//  MiaAPIHelper.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MiaAPIMacro.h"
#import "MiaRequestItem.h"


FOUNDATION_EXPORT NSString *const TimtOutPrompt;            // 请求超时提示
FOUNDATION_EXPORT NSString *const DataParseErrorPrompt;     // 数据解析出错提示
FOUNDATION_EXPORT NSString *const UnknowErrorPrompt;        // 未知错误提示


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
				spID:(NSString *)spID
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

+ (void)getFansListWithUID:(NSString *)uID
					 start:(long)start
					  item:(long)item
			 completeBlock:(MiaRequestCompleteBlock)completeBlock
			  timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)getFollowingListWithUID:(NSString *)uID
						  start:(long)start
						   item:(long)item
				  completeBlock:(MiaRequestCompleteBlock)completeBlock
				   timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)searchUserWithKey:(NSString *)key
					start:(long)start
					 item:(long)item
			completeBlock:(MiaRequestCompleteBlock)completeBlock
			 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)getNotifyWithLastID:(NSString *)notifyID
					   item:(long)item
			  completeBlock:(MiaRequestCompleteBlock)completeBlock
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

+ (void)followWithUID:(NSString *)uID
			 isFollow:(BOOL)isFollow
		completeBlock:(MiaRequestCompleteBlock)completeBlock
		 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)postCommentWithShareID:(NSString *)sID
					   comment:(NSString *)comment
					 commentID:(NSString *)commentID
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

+ (void)thirdLoginWithOpenID:(NSString *)openID
                     unionID:(NSString *)unionID
                       token:(NSString *)token
                    nickName:(NSString *)nickName
                         sex:(NSString *)sex
                        type:(NSString *)type
                      avatar:(NSString *)avatar
               completeBlock:(MiaRequestCompleteBlock)completeBlock
                timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)loginWithPhoneNum:(NSString *)phoneNumber
			 passwordHash:(NSString *)passwordHash
			completeBlock:(MiaRequestCompleteBlock)completeBlock
			 timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)loginWithSession:(NSString *)uID
				   token:(NSString *)token
		   completeBlock:(MiaRequestCompleteBlock)completeBlock
			timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

+ (void)logoutWithCompleteBlock:(MiaRequestCompleteBlock)completeBlock
				   timeoutBlock:(MiaRequestTimeoutBlock)timeoutBlock;

@end
