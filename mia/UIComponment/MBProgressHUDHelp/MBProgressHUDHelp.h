//
//  MBProgressHUDHelp.h
//  mia
//
//  Created by HongBin Lin on 14-9-17.
//  Copyright (c) 2014年 Mia Music. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^RemoveMBProgressHUDBlock)();

@interface MBProgressHUDHelp : NSObject

+(id)standarMBProgressHUDHelp;

/**
 *  显示纯文本的对话框
 *
 *  @param text 文本内容
 */
-(void)showHUDWithModeText:(NSString *)text;

- (void)showHUDWithModeTextAndNoSleep:(NSString *)text;
@end
