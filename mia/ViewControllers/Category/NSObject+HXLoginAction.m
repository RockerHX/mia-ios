//
//  UIViewController+LoginAction.m
//  mia
//
//  Created by miaios on 16/2/23.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "UIViewController+LoginAction.h"

NSString *const kLoginNotification  = @"kLoginNotification";

@implementation NSObject (LoginAction)

- (void)shouldLogin {
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginNotification object:nil];
}

@end
