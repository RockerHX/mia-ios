//
//  HXLoginViewController.m
//  mia
//
//  Created by miaios on 15/11/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXLoginViewController.h"
#import <ShareSDK/ShareSDK.h>
//#import "HXUserSession.h"

typedef NS_ENUM(BOOL, HXLoginAction) {
    HXLoginActionLogin = YES,
    HXLoginActionCancel = NO
};

@interface HXLoginViewController ()
@end

@implementation HXLoginViewController {
    BOOL _shouldHideNavigationBar;
    HXLoginAction _loginAction;
}

#pragma mark - View Controller Life Cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:_shouldHideNavigationBar animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Segue Methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    _shouldHideNavigationBar = NO;
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    _loginAction = HXLoginActionCancel;
}

- (void)viewConfigure {
    ;
}

#pragma mark - Setter And Getter Methods
- (NSString *)navigationControllerIdentifier {
    return @"HXLoginNavigationController";
}

- (HXStoryBoardName)storyBoardName {
    return HXStoryBoardNameLogin;
}

#pragma mark - Event Response
- (IBAction)backButtonPressed {
    [self showAnimation];
}

- (IBAction)weixinButtonPressed {
    _shouldHideNavigationBar = YES;
    [self showHUD];
    
//    __weak __typeof__(self)weakSelf = self;
//    [ShareSDK getUserInfo:SSDKPlatformTypeWechat onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
//        __strong __typeof__(self)strongSelf = weakSelf;
//        if (state == SSDKResponseStateSuccess) {
//            [[HXUserSession share] thirdLoginWithType:HXUserSessionLoginTypeWeiXin userInfo:user success:^(HXUserSession *session, HXApiResponse *response) {
//                [strongSelf loginSuccessWithResponse:response];
//            } failure:^(HXUserSession *session, HXApiResponse *response) {
//                __strong __typeof__(self)strongSelf = weakSelf;
//                [strongSelf showToastWithMessage:response.message];
//            }];
//        } else {
//            [self showToastWithMessage:error.description];
//        }
//    }];
}

- (IBAction)loginButtonPressed {
    _shouldHideNavigationBar = YES;
    switch (_loginAction) {
        case HXLoginActionLogin: {
            if (_mobileTextField.text.length != 11) {
                [self showToastWithMessage:@"请输入正确手机号！"];
            } else if (!_passWordTextField.text.length) {
                [self showToastWithMessage:@"请输入登录密码！"];
            } else {
                [self startLoginRequestWithParameters:@{@"phone": _mobileTextField.text,
                                                          @"pwd": _passWordTextField.text}];
            }
            break;
        }
        case HXLoginActionCancel: {
            [self hiddenAnimation];
            break;
        }
    }
}

#pragma mark - Private Methods
- (void)hiddenAnimation {
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf hiddenOperationWithAction:HXLoginActionLogin];
    } completion:^(BOOL finished) {
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf hiddenAnimationCompletedWithAction:HXLoginActionLogin];
        [strongSelf loginButtonMoveUpAnimation];
    }];
}

- (void)showAnimation {
    __weak __typeof__(self)weakSelf = self;
    [self loginButtonMoveDownAnimationWithCompletion:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf hiddenAnimationCompletedWithAction:HXLoginActionCancel];
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            __strong __typeof__(self)strongSelf = weakSelf;
            [strongSelf hiddenOperationWithAction:HXLoginActionCancel];
        } completion:nil];
    }];
}

- (void)hiddenOperationWithAction:(HXLoginAction)action {
    _loginAction = action;
    
    CGFloat alpha = action ? 0.0f : 1.0f;
    _logoView.alpha = alpha;
    _weixinButton.alpha = alpha;
    _registerView.alpha = alpha;
}

- (void)hiddenAnimationCompletedWithAction:(HXLoginAction)action {
    _loginAction = action;
    
    BOOL hidden = action;
    CGFloat alpha = action ? 1.0f : 0.0f;
    _logoView.hidden = hidden;
    _logoView.alpha = alpha;
    
    _weixinButton.hidden = hidden;
    _weixinButton.alpha = alpha;
    
    _registerView.hidden = hidden;
    _registerView.alpha = alpha;
}

- (void)loginButtonMoveUpAnimation {
    _loginButtonBottomConstraint.constant = 200.0f;
    
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf loginButtonMoveOperationWithAction:HXLoginActionLogin];
    } completion:^(BOOL finished) {
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf loginButtonMoveOperationCompletedWithAction:HXLoginActionLogin];
    }];
}

- (void)loginButtonMoveDownAnimationWithCompletion:(void(^)())completion {
    _loginButtonBottomConstraint.constant = 60.0f;
    
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf loginButtonMoveOperationWithAction:HXLoginActionCancel];
    } completion:^(BOOL finished) {
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf loginButtonMoveOperationCompletedWithAction:HXLoginActionCancel];
        completion();
    }];
}

- (void)loginButtonMoveOperationWithAction:(HXLoginAction)action {
    _loginView.hidden = action ? NO : YES;
    [_loginButton setTitle:(action ? @"登录" : @"Mia账号登录") forState:UIControlStateNormal];
    [self.view layoutIfNeeded];
}

- (void)loginButtonMoveOperationCompletedWithAction:(HXLoginAction)action {
    _backButton.hidden = !action;
    
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf.loginView.alpha = action ? 1.0f : 0.0f;
    } completion:nil];
}

- (void)startLoginRequestWithParameters:(NSDictionary *)parameters {
//    [self showHUD];
//    __weak __typeof__(self)weakSelf = self;
//    [[HXUserSession share] loginWithMobile:_mobileTextField.text passWord:_passWordTextField.text success:^(HXUserSession *session, HXApiResponse *response) {
//        __strong __typeof__(self)strongSelf = weakSelf;
//        [strongSelf loginSuccessWithResponse:response];
//    } failure:^(HXUserSession *session, HXApiResponse *response) {
//        __strong __typeof__(self)strongSelf = weakSelf;
//        [strongSelf showToastWithMessage:response.message];
//    }];
}

- (void)loginRequestHandle {
    ;
}

//- (void)loginSuccessWithResponse:(HXApiResponse *)response {
//    [self hiddenHUD];
//    if (response.statusCode == HXApiRequestStatusCodeOK) {
//        if (response.errorCode == HXAppApiRequestErrorCodeNoError) {
//            [self showToastWithMessage:@"登录成功！"];
//            if (_delegate && [_delegate respondsToSelector:@selector(loginViewControllerLoginSuccess:)]) {
//                [_delegate loginViewControllerLoginSuccess:self];
//            }
//        }
//    }
//    if (response.message) {
//        [self showToastWithMessage:response.message];
//    }
//}

@end
