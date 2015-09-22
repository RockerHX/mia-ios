//
//  MBProgressHUDHelp.m
//  huanjuwan
//
//  Created by HongBin Lin on 14-9-17.
//  Copyright (c) 2014年 duowan. All rights reserved.
//

#import "MBProgressHUDHelp.h"
#import "MBProgressHUD.h"

@implementation MBProgressHUDHelp

+(id)standarMBProgressHUDHelp{
    static MBProgressHUDHelp *hudHelp = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        hudHelp = [[self alloc] init];
    });
    return hudHelp;
}

/**
 *  显示纯文本的对话框
 *
 *  @param text 文本内容
 */
-(void)showHUDWithModeText:(NSString *)text{
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    MBProgressHUD *progressHUD = [[MBProgressHUD alloc] initWithView:window];
    [window addSubview:progressHUD];
    progressHUD.labelText = text;
    progressHUD.mode = MBProgressHUDModeText;
    [progressHUD showAnimated:YES whileExecutingBlock:^{
        sleep(2);
    } completionBlock:^{
        [progressHUD removeFromSuperview];
    }];
}

- (void)showHUDWithModeTextAndNoSleep:(NSString *)text{
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    MBProgressHUD *progressHUD = [[MBProgressHUD alloc] initWithView:window];
    [window addSubview:progressHUD];
    progressHUD.labelText = text;
    progressHUD.mode = MBProgressHUDModeText;
    [progressHUD show:YES];
}

@end
