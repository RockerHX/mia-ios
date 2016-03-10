//
//  HXComment.h
//  mia
//
//  Created by miaios on 15/10/27.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "MJExtension.h"

@interface HXComment : NSObject <NSCopying>

@property (strong, nonatomic) NSString *cmid;
@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSString *nickName;
@property (strong, nonatomic) NSString *headerURL;
@property (strong, nonatomic) NSString *content;
@property (assign, nonatomic) NSInteger time;

@property (strong, nonatomic, readonly) NSString *formatTime;

@end
