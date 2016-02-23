//
//  UserItem.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserItem : NSObject <NSCoding, NSCopying>

@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSString *nick;
@property (strong, nonatomic) NSString *userpic;
@property (strong, nonatomic) NSString *sharem;
@property (assign, nonatomic) BOOL follow;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
