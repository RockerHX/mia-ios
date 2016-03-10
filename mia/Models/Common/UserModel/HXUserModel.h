//
//  HXUserModel.h
//  mia
//
//  Created by miaios on 16/2/23.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "MJExtension.h"

@interface HXUserModel : NSObject

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, assign) NSInteger notifyCount;
@property (nonatomic, strong) NSString *notifyAvatar;

@end
