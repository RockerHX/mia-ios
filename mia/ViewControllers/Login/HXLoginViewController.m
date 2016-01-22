//
//  HXLoginViewController.m
//  mia
//
//  Created by miaios on 15/11/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXLoginViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "NSString+MD5.h"
#import "MiaAPIHelper.h"
#import "UserSession.h"
#import "HXAlertBanner.h"
#import "UserDefaultsUtils.h"

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
    
    NSString *mobile = _mobileTextField.text;
    NSString *password = _passWordTextField.text;
    
    switch (_loginAction) {
        case HXLoginActionLogin: {
            if (mobile.length != 11) {
                [self showToastWithMessage:@"请输入正确手机号！"];
            } else if (!password.length) {
                [self showToastWithMessage:@"请输入登录密码！"];
            } else {
                [self startLoginRequestWithMobile:mobile password:password];
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

- (void)startLoginRequestWithMobile:(NSString *)mobile password:(NSString *)password {
    [self showHUD];
    
    __weak __typeof__(self)weakSelf = self;
    NSString *passwordHash = [NSString md5HexDigest:password];
    [MiaAPIHelper loginWithPhoneNum:mobile
                       passwordHash:passwordHash
                      completeBlock:
     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
         __strong __typeof__(self)strongSelf = weakSelf;
         if (success) {
             [[UserSession standard] setUid:userInfo[MiaAPIKey_Values][@"uid"]];
             [[UserSession standard] setNick:userInfo[MiaAPIKey_Values][@"nick"]];
             [[UserSession standard] setUtype:userInfo[MiaAPIKey_Values][@"utype"]];
             [[UserSession standard] setUnreadCommCnt:userInfo[MiaAPIKey_Values][@"unreadCommCnt"]];
             
             NSString *avatarUrl = userInfo[MiaAPIKey_Values][@"userpic"];
             NSString *avatarUrlWithTime = [NSString stringWithFormat:@"%@?t=%ld", avatarUrl, (long)[[NSDate date] timeIntervalSince1970]];
             
             UserSession *userSession = [UserSession standard];
             userSession.state = UserSessionLoginStateLogin;
             [userSession setAvatar:avatarUrlWithTime];
             [userSession saveAuthInfoMobile:mobile password:password];
             [userSession saveUserInfoUid:userInfo[MiaAPIKey_Values][@"uid"] nickName:userInfo[MiaAPIKey_Values][@"nick"]];
             
             if (_delegate && [_delegate respondsToSelector:@selector(loginViewControllerLoginSuccess:)]) {
                 [_delegate loginViewControllerLoginSuccess:self];
             }
             
             [strongSelf dismissViewControllerAnimated:YES completion:nil];
         } else {
             id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
             [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
         }
         
         [strongSelf hiddenHUD];
     } timeoutBlock:^(MiaRequestItem *requestItem) {
         __strong __typeof__(self)strongSelf = weakSelf;
         [HXAlertBanner showWithMessage:@"请求超时，请稍后重试" tap:nil];
         [strongSelf hiddenHUD];
     }];
}

- (void)loginRequestHandle {
    ;
}

@end