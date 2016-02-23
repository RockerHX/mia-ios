//
//  HXUserModel.m
//  mia
//
//  Created by miaios on 16/2/23.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXUserModel.h"

@implementation HXUserModel

MJCodingImplementation

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"nickName": @"nick",
                 @"type": @"utype",
               @"avatar": @"userpic",
          @"notifyCount": @"notifyCnt",
         @"notifyAvatar": @"notifyUserpic"};
}

+ (instancetype)mj_objectWithKeyValues:(id)keyValues {
    HXUserModel *model = [super mj_objectWithKeyValues:keyValues];
    model.uid = [NSString stringWithFormat:@"%@", model.uid];
    return model;
}

@end
