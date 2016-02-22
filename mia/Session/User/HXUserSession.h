//
//  HXUserSession.h
//  mia
//
//  Created by miaios on 16/2/22.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(BOOL, HXUserState) {
    HXUserStateLogout,
    HXUserStateLogin
};

@interface HXUserSession : NSObject

@property (nonatomic, assign, readonly) HXUserState state;


+ (instancetype)share;

- (void)logout;

@end
