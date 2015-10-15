//
//  InfectUserItem.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

@interface InfectUserItem : NSObject <NSCoding>

@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSString *avatar;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
