//
//  UpdateHelper.m
//
//
//  Created by linyehui on 2015/10/24.
//  Copyright (c) 2015年 linyehui. All rights reserved.
//

#import "UpdateHelper.h"
#import "UserDefaultsUtils.h"
#import "MiaAPIHelper.h"
#import "NSString+IsNull.h"
#import "UIAlertView+BlocksKit.h"

static NSString * const UserDefaultsKey_LastUpdateTimestamp	= @"LastUpdateTimestamp";
static double kMaxUpdateTimeInterval = 60 * 60 * 24;	// 24 Hours

@implementation UpdateHelper {
}

- (id) init {
    if (self == [super init]) {
    }
    
    return self;
}

- (void)checkNow {
	double lastUpdateTime = [UserDefaultsUtils doubleValueWithKey:UserDefaultsKey_LastUpdateTimestamp];
	double currentTime = [[NSDate date] timeIntervalSince1970];
	double timeInterval = currentTime - lastUpdateTime;
	NSLog(@"check update: %f - %f = %f", lastUpdateTime, currentTime, timeInterval);

	if (lastUpdateTime > 0 && timeInterval < kMaxUpdateTimeInterval)
		return;

	[UserDefaultsUtils saveDoubleValue:currentTime withKey:UserDefaultsKey_LastUpdateTimestamp];
	[MiaAPIHelper getUpdateInfoWithCompleteBlock:
	 ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
		 if (success) {
			 NSString *msg = userInfo[MiaAPIKey_Values][@"data"][@"msg"];
			 NSString *version = userInfo[MiaAPIKey_Values][@"data"][@"version"];
			 NSString *url = userInfo[MiaAPIKey_Values][@"data"][@"url"];
			 if ([NSString isNull:msg]
				 || [NSString isNull:version]
				 || [NSString isNull:url]) {
				 return ;
			 }

			 if ([self checkIsNeedUpdateWithVersion:version]) {
				 [self showUpdateTipsWithMsg:msg version:version url:url];
			 }

			 NSLog(@"get update info success");
		 } else {
			 NSLog(@"get update info failed");
		 }
		NSLog(@"...");
	} timeoutBlock:^(MiaRequestItem *requestItem) {
		NSLog(@"get update info timeout");
	}];
}

- (BOOL)checkIsNeedUpdateWithVersion:(NSString *)version {
	NSString *buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	NSString *shortVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	NSString *currentVersion = [NSString stringWithFormat:@"%@.%@", shortVersion, buildVersion];

	if ([self isVersion:version biggerThanVersion:currentVersion]) {
		return YES;
	}

	return NO;
}

- (void)showUpdateTipsWithMsg:(NSString *)msg version:(NSString *)version url:(NSString *)url {
	static NSString *kAlertTitle = @"升级提示";

	[UIAlertView bk_showAlertViewWithTitle:kAlertTitle
								   message:msg
						 cancelButtonTitle:@"取消"
						 otherButtonTitles:@[@"马上升级"]
								   handler:
	 ^(UIAlertView *alertView, NSInteger buttonIndex) {
		 if (alertView.cancelButtonIndex == buttonIndex) {
			 NSLog(@"cancel update");
		 } else {
			 NSLog(@"update now");
			 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
		 }
	 }];
}


- (BOOL)isVersion:(NSString*)versionA biggerThanVersion:(NSString*)versionB {
	NSArray *arrayNow = [versionB componentsSeparatedByString:@"."];
	NSArray *arrayNew = [versionA componentsSeparatedByString:@"."];
	BOOL isBigger = NO;
	NSInteger i = arrayNew.count > arrayNow.count? arrayNow.count : arrayNew.count;
	NSInteger j = 0;
	BOOL hasResult = NO;

	for (j = 0; j < i; j ++) {
		NSString* strNew = [arrayNew objectAtIndex:j];
		NSString* strNow = [arrayNow objectAtIndex:j];

		if ([strNew integerValue] > [strNow integerValue]) {
			hasResult = YES;
			isBigger = YES;
			break;
		}

		if ([strNew integerValue] < [strNow integerValue]) {
			hasResult = YES;
			isBigger = NO;
			break;
		}
	}

	if (!hasResult) {
		if (arrayNew.count > arrayNow.count) {
			NSInteger nTmp = 0;
			NSInteger k = 0;
			for (k = arrayNow.count; k < arrayNew.count; k++) {
				nTmp += [[arrayNew objectAtIndex:k]integerValue];
			}
			if (nTmp > 0) {
				isBigger = YES;
			}
		}
	}
	return isBigger;
}

@end
