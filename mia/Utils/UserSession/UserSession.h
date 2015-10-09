//
//  UserSession.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

/*
 "{"C":"User.Post.Login","s":"1442905599693","v":{"ret":0,"uid":"291","nick":"eden","utype":"1","unreadCommCnt":"0"}}"
 */

static NSString * const UserDefaultsKey_UserName			= @"name";
static NSString * const UserDefaultsKey_PasswordHash		= @"hash";

@interface UserSession : NSObject

@property (assign, nonatomic) BOOL isLogined;
@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSString *nick;
@property (strong, nonatomic) NSString *utype;
@property (strong, nonatomic) NSString *unreadCommCnt;

/**
 *  使用单例初始化
 *
 */
+ (id)standard;

- (void)logout;

@end
