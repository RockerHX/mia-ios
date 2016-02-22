//
//  HXUserSession.m
//  mia
//
//  Created by miaios on 16/2/22.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXUserSession.h"

@implementation HXUserSession

#pragma mark - Singleton Methods
+ (instancetype)share {
    static HXUserSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        session = [[HXUserSession alloc] init];
    });
    return session;
}

#pragma mark - Property
- (HXUserState)state {
    return HXUserStateLogout;
}

#pragma mark - Public Methods
- (void)logout {
    ;
}

@end
