//
//  PathHelper.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//
//

#import "PathHelper.h"
#import "NSString+IsNull.h"

@interface PathHelper()

@end

@implementation PathHelper {
}

+ (NSString *)cacheDir {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *dirPath = [DOCUMENT_PATH stringByAppendingPathComponent:@"/Cache"];
	if(![fileManager fileExistsAtPath:dirPath]) {
		[fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
	}
	return dirPath;
}

+ (NSString *)playCacheDir {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *dirPath = [DOCUMENT_PATH stringByAppendingPathComponent:@"/Cache/Play"];
	if(![fileManager fileExistsAtPath:dirPath]) {
		[fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
	}
	return dirPath;
}

+ (NSString *)favoriteCacheDir {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *dirPath = [DOCUMENT_PATH stringByAppendingPathComponent:@"/Cache/Favorite"];
	if(![fileManager fileExistsAtPath:dirPath]) {
		[fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
	}
	return dirPath;
}

+ (NSString *)userDirWithUID:(NSString *)uid {
	NSString *uidPath = [NSString isNull:uid] ? @"0" : uid;
	NSString *subDir = [NSString stringWithFormat:@"/User/%@", uidPath];

	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *dirPath = [DOCUMENT_PATH stringByAppendingPathComponent:subDir];
	if(![fileManager fileExistsAtPath:dirPath]) {
		[fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
	}
	return dirPath;
}

+ (NSString *)shareArchivePathWithUID:(NSString *)uid {
	return [NSString stringWithFormat:@"%@/sharelist.archive", [self userDirWithUID:uid]];
}

+ (NSString *)favoriteArchivePathWithUID:(NSString *)uid {
	return [NSString stringWithFormat:@"%@/favorite.archive", [self userDirWithUID:uid]];
}

@end
















