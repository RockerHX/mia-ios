//
//  MessageItem.h
//  mia
//
//  Created by miaios on 16/1/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "MJExtension.h"

@interface MessageItem : NSObject

@property (strong, nonatomic) NSString *notifyID;
@property (strong, nonatomic) NSString *toUID;
@property (strong, nonatomic) NSString *fromUID;
@property (strong, nonatomic) NSString *fromUserName;
@property (strong, nonatomic) NSString *fromUserpic;
@property (assign, nonatomic) NSInteger ntype;
@property (strong, nonatomic) NSString *sID;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) NSInteger time;
@property (assign, nonatomic) BOOL hasReaded;

@property (assign, nonatomic, readonly) BOOL navigateToUser;
@property (nonatomic, strong, readonly) NSString *formatTime;

@end
