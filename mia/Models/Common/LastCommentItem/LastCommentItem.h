//
//  LastCommentItem.h
//  
//
//  Created by linyehui on 2016/02/29.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LastCommentItem : NSObject <NSCoding>

@property (strong, nonatomic) NSString *comment;
@property (strong, nonatomic) NSString *uID;
@property (strong, nonatomic) NSString *nick;
@property (assign, nonatomic) NSInteger time;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
