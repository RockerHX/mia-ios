//
//  NSObject+LoginAction.h
//  mia
//
//  Created by miaios on 16/2/23.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString *const kLoginNotification;

@interface NSObject (LoginAction)

- (void)shouldLogin;

@end
