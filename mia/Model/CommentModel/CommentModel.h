//
//  CommentModel.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentModel : NSObject

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSString *lastCommentID;
@property (nonatomic, strong) NSString *latestCommentID;

- (void)addComments:(NSArray *) comments;

@end
