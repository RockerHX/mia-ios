//
//  CommentItem.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentItem : NSObject

@property (strong, nonatomic) NSString *cmid;
@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSString *unick;
@property (strong, nonatomic) NSString *uimg;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *edate;
@property (strong, nonatomic) NSString *cinfo;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
