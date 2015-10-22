//
//  InfectUserItem.h
//  用于显示妙推头像的Item封装
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

@interface InfectUserItem : NSObject <NSCoding>

@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSString *avatar;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
