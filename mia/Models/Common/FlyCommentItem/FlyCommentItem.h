//
//  FlyCommentItem.h
//  
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlyCommentItem : NSObject <NSCoding>

@property (strong, nonatomic) NSString *userpic;
@property (strong, nonatomic) NSString *comment;
@property (assign, nonatomic) NSInteger time;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
