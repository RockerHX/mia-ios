//
//  HXProfileHeaderModel.m
//  mia
//
//  Created by miaios on 16/2/29.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXProfileHeaderModel.h"

@implementation HXProfileHeaderModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"avatar": @"uimg",
           @"nickName": @"nick",
          @"fansCount": @"fansCnt",
        @"followCount": @"followCnt"};
}

@end
