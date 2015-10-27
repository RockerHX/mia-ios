//
//  HXComment.m
//  mia
//
//  Created by miaios on 15/10/27.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXComment.h"

@implementation HXComment

+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{@"nickName": @"unick",
            @"headerURL": @"uimg",
             @"editDate": @"edate",
              @"content": @"cinfo"};
}

@end
