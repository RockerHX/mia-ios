//
//  CacheHelper.m
//
//
//  Created by linyehui on 2015/11/02.
//  Copyright (c) 2015年 linyehui. All rights reserved.
//

#import "CacheHelper.h"
#import "SDWebImageManager.h"
#import "PathHelper.h"


@implementation CacheHelper {
}

#pragma mark - Public Methods
+ (void)checkCacheSizeWithCompleteBlock:(void (^)(unsigned long long))completeBlock {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		unsigned long long totalSize = 0;

		NSUInteger imageCacheSize = [[SDImageCache sharedImageCache] getSize];
		totalSize += imageCacheSize;

		unsigned long long logDirSize = [self calcDiskSizeOfDir:[PathHelper logDir]];
		totalSize += logDirSize;

		unsigned long long cacheDirSize = [self calcDiskSizeOfDir:[PathHelper cacheDir]];
		totalSize += cacheDirSize;

		unsigned long long userDirSize = [self calcDiskSizeOfDir:[PathHelper userDir]];
		totalSize += userDirSize;

		dispatch_async(dispatch_get_main_queue(), ^{
			if (completeBlock) {
				completeBlock(totalSize);
			}
		});
	});
}

+ (void)cleanCacheWithCompleteBlock:(void (^)())completeBlock {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[[SDImageCache sharedImageCache] cleanDisk];

		[self deleteFilesInDir:[PathHelper logDir]];
		[self deleteFilesInDir:[PathHelper cacheDir]];
		[self deleteFilesInDir:[PathHelper userDir]];

		dispatch_async(dispatch_get_main_queue(), ^{
			if (completeBlock) {
				completeBlock();
			}
		});
	});
}

#pragma mark - Private Methods
+ (unsigned long long)calcDiskSizeOfDir:(NSString *)cacheDir {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *cacheFileList;
	NSEnumerator *cacheEnumerator;
	NSString *itemFilePath;

	unsigned long long cacheFolderSize = 0;

	cacheFileList = [fileManager subpathsOfDirectoryAtPath:cacheDir error:nil];
	cacheEnumerator = [cacheFileList objectEnumerator];
	while (itemFilePath = [cacheEnumerator nextObject]) {
		NSDictionary *cacheFileAttributes = [fileManager attributesOfItemAtPath:[cacheDir stringByAppendingPathComponent:itemFilePath] error:nil];
		cacheFolderSize += [cacheFileAttributes fileSize];
	}

	return cacheFolderSize;
}

+ (void)deleteFilesInDir:(NSString *)cacheDir {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *contents = [fileManager contentsOfDirectoryAtPath:cacheDir error:NULL];
	NSEnumerator *enumer = [contents objectEnumerator];
	NSString *filename;
	while ((filename = [enumer nextObject])) {
		[fileManager removeItemAtPath:[cacheDir stringByAppendingPathComponent:filename] error:NULL];
	}
}

@end
