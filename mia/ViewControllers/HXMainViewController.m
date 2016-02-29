//
//  HXMainViewController.m
//  Mia
//
//  Created by miaios on 15/12/4.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXMainViewController.h"
#import "HXDiscoveryViewController.h"
#import "HXFavoriteViewController.h"
#import "HXMeViewController.h"
#import "HXUserSession.h"
#import "HXLoginViewController.h"
#import "UIViewController+LoginAction.h"
#import "WebSocketMgr.h"
#import "MiaAPIHelper.h"
#import "HXNoNetworkView.h"
#import "HXAlertBanner.h"
#import "UpdateHelper.h"

@interface HXMainViewController () <
UITabBarControllerDelegate
>
@end

@implementation HXMainViewController

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

- (void)dealloc {
    // Socket
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidOpen object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidFailWithError object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidAutoReconnectFailed object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationPushUnread object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidCloseWithCode object:nil];
    
    // Login
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginNotification object:nil];
}

#pragma mark - Config Methods
- (void)loadConfigure {
    self.delegate = self;
    
    // Socket
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidOpen:) name:WebSocketMgrNotificationDidOpen object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidFailWithError:) name:WebSocketMgrNotificationDidFailWithError object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidAutoReconnectFailed:) name:WebSocketMgrNotificationDidAutoReconnectFailed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketPushUnread:) name:WebSocketMgrNotificationPushUnread object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidCloseWithCode:) name:WebSocketMgrNotificationDidCloseWithCode object:nil];
    
    // Login
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoginSence) name:kLoginNotification object:nil];
}

- (void)viewConfigure {
    [self subControllersConfigure];
}

- (void)subControllersConfigure {
    for (UINavigationController *navigationController in self.viewControllers) {
        if ([navigationController.restorationIdentifier isEqualToString:[HXDiscoveryViewController navigationControllerIdentifier]]) {
            [navigationController setViewControllers:@[[HXDiscoveryViewController instance]]];
        } else if ([navigationController.restorationIdentifier isEqualToString:[HXFavoriteViewController navigationControllerIdentifier]]) {
            [navigationController setViewControllers:@[[HXFavoriteViewController instance]]];
        } else if ([navigationController.restorationIdentifier isEqualToString:[HXMeViewController navigationControllerIdentifier]]) {
            [navigationController setViewControllers:@[[HXMeViewController instance]]];
        }
    }
}

#pragma mark - Socket
- (void)notificationWebSocketDidOpen:(NSNotification *)notification {
    [HXNoNetworkView hidden];
    [MiaAPIHelper sendUUIDWithCompleteBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
        if (success) {
			[self checkUpdate];

            if (![self autoLogin]) {
                HXDiscoveryViewController *discoveryViewController = [((UINavigationController *)[self.viewControllers firstObject]).viewControllers firstObject];
                [discoveryViewController fetchShareList];
#warning TODO
                //[_radioView checkIsNeedToGetNewItems];
            }
        } else {
            [self autoReconnect];
        }
    } timeoutBlock:^(MiaRequestItem *requestItem) {
        [self autoReconnect];
    }];
}

- (void)notificationWebSocketDidFailWithError:(NSNotification *)notification {
    // TODO auto reconnect
    static NSString * kAlertMsgWebSocketFailed = @"服务器不稳定，重连中";
    [HXAlertBanner showWithMessage:kAlertMsgWebSocketFailed tap:nil];
}

- (void)notificationWebSocketDidAutoReconnectFailed:(NSNotification *)notification {
    [self showNoNetworkView];
}

- (void)notificationWebSocketPushUnread:(NSNotification *)notification {
    id ret = [notification userInfo][MiaAPIKey_Values][MiaAPIKey_Return];
    if (0 == [ret intValue]) {
        NSInteger notifyCount = [[notification userInfo][MiaAPIKey_Values][@"notifyCnt"] integerValue];
//        [[UserSession standard] setNotifyUserpic:[notification userInfo][MiaAPIKey_Values][@"notifyUserpic"]];
//        [[UserSession standard] setNotifyCnt:notifyCount];
    } else {
        NSLog(@"notify count parse failed! error:%@", [notification userInfo][MiaAPIKey_Values][MiaAPIKey_Error]);
    }
}

- (void)notificationWebSocketDidCloseWithCode:(NSNotification *)notification {
    NSLog(@"Connection Closed! (see logs)");
}

- (void)checkUpdate {
	UpdateHelper *aUpdateHelper = [[UpdateHelper alloc] init];
	[aUpdateHelper checkNow];
}

- (BOOL)autoLogin {
//    NSString *uid = [UserDefaultsUtils valueWithKey:UserDefaultsKey_SessionUID];
//    NSString *token = [UserDefaultsUtils valueWithKey:UserDefaultsKey_SessionToken];
//    if ([NSString isNull:uid] || [NSString isNull:token]) {
//        return NO;
//    }
//    
//    [MiaAPIHelper loginWithSession:uid
//                             token:token
//                     completeBlock:
//     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
//         if (success) {
//             [[UserSession standard] setUid:[NSString stringWithFormat:@"%@", userInfo[MiaAPIKey_Values][@"uid"]]];
//             [[UserSession standard] setNick:userInfo[MiaAPIKey_Values][@"nick"]];
//             [[UserSession standard] setUtype:userInfo[MiaAPIKey_Values][@"utype"]];
//             [[UserSession standard] setNotifyCnt:[userInfo[MiaAPIKey_Values][@"notifyCnt"] integerValue]];
//             [[UserSession standard] setNotifyUserpic:userInfo[MiaAPIKey_Values][@"notifyUserpic"]];
//             
//             NSString *avatarUrl = userInfo[MiaAPIKey_Values][@"userpic"];
//             NSString *avatarUrlWithTime = [NSString stringWithFormat:@"%@?t=%ld", avatarUrl, (long)[[NSDate date] timeIntervalSince1970]];
//             [[UserSession standard] setAvatar:avatarUrlWithTime];
//             [UserDefaultsUtils saveValue:userInfo[MiaAPIKey_Values][@"uid"] forKey:UserDefaultsKey_UID];
//             [UserDefaultsUtils saveValue:userInfo[MiaAPIKey_Values][@"nick"] forKey:UserDefaultsKey_Nick];
//             [UserSession standard].state = UserSessionLoginStateLogin;
//         } else {
//             [[FileLog standard] log:@"autoLogin failed, logout"];
//             [[UserSession standard] logout];
//         }
//         
//         [_radioViewController loadShareList];
//     } timeoutBlock:^(MiaRequestItem *requestItem) {
//         NSLog(@"audo login timeout!");
//         [_radioViewController loadShareList];
//     }];
    return NO;
}

- (void)autoReconnect {
    // TODO auto reconnect
    [[WebSocketMgr standard] reconnect];
}

#pragma mark - Private Methods
- (void)showLoginSence {
    [self presentViewController:[HXLoginViewController navigationControllerInstance] animated:YES completion:nil];
}

- (void)showNoNetworkView {
    [HXNoNetworkView showOnViewController:self show:nil play:nil];
}

#pragma mark - UITabBarControllerDelegate Methods
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (![[self.viewControllers firstObject] isEqual:viewController]) {
        switch ([HXUserSession share].userState) {
            case HXUserStateLogout: {
                [self showLoginSence];
                return NO;
                break;
            }
            case HXUserStateLogin: {
                return YES;
                break;
            }
        }
    }
    return YES;
}

@end
