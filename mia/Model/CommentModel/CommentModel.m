//
//  CommentModel.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "CommentModel.h"
#import "CommentItem.h"

@implementation CommentModel

- (id)init {
	self = [super init];
	if(self) {
		_dataSource = [[NSMutableArray alloc] init];
	}

	return self;
}

- (void)populateDataSource {
	// for test 生成测试用的数据源
	NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:2];
	NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:
						  @"教授", @"name",
						  @"http://tp2.sinaimg.cn/3887950137/50/40038345868/1", @"avatar",
						  @"不错哦，超喜欢这种风格的歌曲。", @"comment",
						  nil];
	CommentItem *item1 = [[CommentItem alloc] initWithDictionary:dic1];
	[result addObject:item1];

	NSDictionary *dic2 = [NSDictionary dictionaryWithObjectsAndKeys:
						  @"Simons", @"name",
						  @"http://tp4.sinaimg.cn/1771150371/50/5624455053/1", @"avatar",
						  @"我要午休，下午去考试 :(", @"comment",
						  nil];
	CommentItem *item2 = [[CommentItem alloc] initWithDictionary:dic2];
	[result addObject:item2];

	self.dataSource = result;
}

- (void)addComments:(NSArray *) comments {

	if (comments.count == 1 && _dataSource) {
		CommentItem *commentItem = [[CommentItem alloc] initWithDictionary:comments[0]];
		if ([commentItem.cmid intValue] > [_lastCommentID intValue]) {
			// 由于我们的评论是最新的在最前面，所以发表评论后需要把自己最新的评论获取到
			[_dataSource insertObject:commentItem atIndex:0];
			return;
		}
	}

	NSMutableArray *result = [[NSMutableArray alloc] init];
	for (id item in comments) {
		CommentItem *commentItem = [[CommentItem alloc] initWithDictionary:item];
		[result addObject:commentItem];
		_lastCommentID = commentItem.cmid;
	}

	if (self.dataSource) {
		[self.dataSource addObjectsFromArray:result];
	} else {
		self.dataSource = result;
	}
}

@end
