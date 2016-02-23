//
//  InfectItem.h
//  用于InfectList的Item封装
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InfectItem : NSObject

@property (strong, nonatomic) NSString *infectid;
@property (strong, nonatomic) NSString *uID;
@property (strong, nonatomic) NSString *nick;
@property (strong, nonatomic) NSString *avatar;
@property (strong, nonatomic) NSString *lastShare;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
