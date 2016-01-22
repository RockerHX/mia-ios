//
//  HXForgotPWViewController.m
//  Mia
//
//  Created by miaios on 16/1/5.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXForgotPWViewController.h"
#import "HXCaptchButton.h"
//#import "HXAppApiRequest.h"

static NSString *CaptchApi = @"/user/pauth";
static NSString *ResetPWApi = @"/user/pauth";

@interface HXForgotPWViewController ()
@end

@implementation HXForgotPWViewController

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    __weak __typeof__(self)weakSelf = self;
    [_captchaButton timingStart:^BOOL(HXCaptchButton *button) {
        __strong __typeof__(self)strongSelf = weakSelf;
        NSString *mobile = strongSelf.mobileTextField.text;
        if (mobile.length != 11) {
            [self showToastWithMessage:@"请输入正确手机号！"];
            return NO;
        } else {
            [strongSelf sendSecurityCodeRequesetWithParameters:@{@"phone": mobile}];
        }
        return YES;
    } end:nil];
}

- (void)viewConfigure {
    ;
}

#pragma mark - Event Response
- (IBAction)resetButtonPressed {
    if (_mobileTextField.text.length != 11) {
        [self showToastWithMessage:@"请输入正确手机号！"];
    } else if (_captchaTextField.text.length < 4) {
        [self showToastWithMessage:@"请输入正确验证码！"];
    } else if (!_passWordTextField.text.length) {
        [self showToastWithMessage:@"请输入登录密码！"];
    } else if (![_passWordTextField.text isEqualToString:_confirmTextField.text]) {
        [self showToastWithMessage:@"亲，您输入的两次密码不相同噢！"];
    } else {
        if ([_confirmTextField.text isEqualToString:_passWordTextField.text]) {
            [self startResetPWRequestWithParameters:@{@"mobile": _mobileTextField.text,
                                                     @"captcha": _captchaTextField.text,
                                                    @"password": _passWordTextField.text}];
        }
    }
}

#pragma mark - Private Methods
- (void)sendSecurityCodeRequesetWithParameters:(NSDictionary *)parameters {
//    __weak __typeof__(self)weakSelf = self;
//    [HXAppApiRequest requestPOSTMethodsWithAPI:[HXApi apiURLWithApi:CaptchApi] parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        __strong __typeof__(self)strongSelf = weakSelf;
//        const NSInteger statusCode = ((NSHTTPURLResponse *)task.response).statusCode;
//        NSString *message = responseObject[@"msg"];
//        if (statusCode == HXApiRequestStatusCodeOK) {
//            const NSInteger errorCode = [responseObject[@"code"] integerValue];
//            if (errorCode == HXAppApiRequestErrorCodeNoError) {
//                ;
//            }
//        }
//        if (message.length) {
//            [strongSelf showToastWithMessage:message];
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        __strong __typeof__(self)strongSelf = weakSelf;
//        [strongSelf showToastWithMessage:NetWorkingError];
//    }];
}

- (void)startResetPWRequestWithParameters:(NSDictionary *)parameters {
//    [self showHUD];
//    __weak __typeof__(self)weakSelf = self;
//    [HXAppApiRequest requestPOSTMethodsWithAPI:[HXApi apiURLWithApi:ResetPWApi] parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        __strong __typeof__(self)strongSelf = weakSelf;
//        [strongSelf hiddenHUD];
//        
//        const NSInteger statusCode = ((NSHTTPURLResponse *)task.response).statusCode;
//        NSString *message = responseObject[@"msg"];
//        if (statusCode == HXApiRequestStatusCodeOK) {
//            const NSInteger errorCode = [responseObject[@"code"] integerValue];
//            if (errorCode == HXAppApiRequestErrorCodeNoError) {
//                NSDictionary *data = responseObject[@"data"];
//                [strongSelf resetSuccessWithData:data];
//            }
//        }
//        if (message) {
//            [strongSelf showToastWithMessage:message];
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        __strong __typeof__(self)strongSelf = weakSelf;
//        [strongSelf showToastWithMessage:NetWorkingError];
//    }];
}

- (void)resetSuccessWithData:(NSDictionary *)data {
    ;
    [self resetSuccess];
}

- (void)resetSuccess {
    [self showToastWithMessage:@"密码重置成功！"];
}

@end
