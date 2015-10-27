//
//  CommentModel.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "CommentModel.h"
#import "HXComment.h"

@implementation CommentModel

- (id)init {
	self = [super init];
	if(self) {
		_dataSource = [[NSMutableArray alloc] init];
		_lastCommentID = @"0";
		_latestCommentID = @"0";
	}

	return self;
}

- (void)addComments:(NSArray *) comments {
	if (comments.count == 1 && _dataSource) {
        HXComment *comment = [HXComment objectWithKeyValues:comments[0]];
		if ([comment.cmid intValue] > [_lastCommentID intValue]) {
			// 由于我们的评论是最新的在最前面，所以发表评论后需要把自己最新的评论获取到
			[_dataSource insertObject:comment atIndex:0];
			_lastCommentID = [[_dataSource lastObject] cmid];
			return;
		}
	}

	NSMutableArray *result = [[NSMutableArray alloc] init];

    for (id item in comments) {
        HXComment *comment = [HXComment objectWithKeyValues:item];
		[result addObject:comment];
		_lastCommentID = comment.cmid;	}

	if (self.dataSource) {
		[self.dataSource addObjectsFromArray:result];
	} else {
		self.dataSource = result;
	}
}

@end
