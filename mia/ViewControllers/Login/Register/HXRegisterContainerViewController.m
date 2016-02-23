//
//  HXRegisterContainerViewController.m
//  mia
//
//  Created by miaios on 16/2/3.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXRegisterContainerViewController.h"
#import "HXRegisterViewController.h"
#import "HXCaptchButton.h"
#import "HXAlertBanner.h"
//#import "MiaAPIHelper.h"
//#import "NSString+MD5.h"

static NSString *RegisterApi = @"/user/register";
static NSString *CaptchApi = @"/user/pauth";

@interface HXRegisterContainerViewController ()
@end

@implementation HXRegisterContainerViewController

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
        
        if ([self checkPhoneNumber]) {
            [strongSelf sendCaptchaRequesetWithMobile:mobile];
            return YES;
        } else {
            return NO;
        }
    } end:nil];
}

- (void)viewConfigure {
    ;
}

#pragma mark - Event Response
- (IBAction)registerButtonPressed {
    if ([self checkPhoneNumber]) {
        if (_captchaTextField.text.length < 4) {
            [self showToastWithMessage:@"请输入正确验证码！"];
        } else if (!_nickNameTextField.text.length) {
            [self showToastWithMessage:@"请输入用户昵称！"];
        } else if (!_passWordTextField.text.length) {
            [self showToastWithMessage:@"请输入登录密码！"];
        } else if (![_passWordTextField.text isEqualToString:_confirmTextField.text]) {
            [self showToastWithMessage:@"亲，您输入的两次密码不相同噢！"];
        } else {
            [self startRegisterRequestWithMobile:_mobileTextField.text
                                         captcha:_captchaTextField.text
                                        nickName:_nickNameTextField.text
                                        password:_passWordTextField.text];
        }
    }
}

#pragma mark - Private Methods
- (BOOL)checkPhoneNumber {
    NSString *str = _mobileTextField.text;
    if (str.length == 11
        && [str rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]].location != NSNotFound) {
        return YES;
    }
    [HXAlertBanner showWithMessage:@"手机号码不符合规范，请重新输入" tap:nil];
    return NO;
}

- (void)sendCaptchaRequesetWithMobile:(NSString *)mobile {
//    __weak __typeof__(self)weakSelf = self;
//    [MiaAPIHelper getVerificationCodeWithType:0
//                                  phoneNumber:mobile
//                                completeBlock:
//     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
//         __strong __typeof__(self)strongSelf = weakSelf;
//         if (success) {
//             [HXAlertBanner showWithMessage:@"验证码已经发送" tap:nil];
//         } else {
//             id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
//             [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
//             [strongSelf.captchaButton stop];
//         }
//     } timeoutBlock:^(MiaRequestItem *requestItem) {
//         __strong __typeof__(self)strongSelf = weakSelf;
//         [HXAlertBanner showWithMessage:@"验证码发送超时，请重新获取" tap:nil];
//         [strongSelf.captchaButton stop];
//     }];
}

- (void)startRegisterRequestWithMobile:(NSString *)mobile captcha:(NSString *)captcha nickName:(NSString *)nickName password:(NSString *)password {
//    [self showHUD];
//    __weak __typeof__(self)weakSelf = self;
//    [MiaAPIHelper registerWithPhoneNum:mobile
//                                 scode:captcha
//                              nickName:nickName
//                          passwordHash:[NSString md5HexDigest:password]
//                         completeBlock:
//     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
//         __strong __typeof__(self)strongSelf = weakSelf;
//         if (success) {
//             [strongSelf registerSuccess];
//         } else {
//             [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", userInfo[MiaAPIKey_Values][MiaAPIKey_Error]] tap:nil];
//         }
//         
//         [strongSelf hiddenHUD];
//     } timeoutBlock:^(MiaRequestItem *requestItem) {
//         __strong __typeof__(self)strongSelf = weakSelf;
//         [HXAlertBanner showWithMessage:@"注册失败，网络请求超时" tap:nil];
//         [strongSelf hiddenHUD];
//     }];
}

- (void)registerSuccessWithData:(NSDictionary *)data {
    [self registerSuccess];
}

- (void)registerSuccess {
    [HXAlertBanner showWithMessage:@"注册成功" tap:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
