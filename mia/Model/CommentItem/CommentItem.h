//
//  CommentItem.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//


@interface CommentItem : NSObject

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *userAvatar;
@property (strong, nonatomic) NSString *comment;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
