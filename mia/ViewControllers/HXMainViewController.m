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
#import "NSObject+LoginAction.h"
#import "WebSocketMgr.h"
#import "MiaAPIHelper.h"
#import "HXNoNetworkView.h"
#import "HXAlertBanner.h"
#import "UpdateHelper.h"
#import "FileLog.h"

@interface HXMainViewController () <
UITabBarControllerDelegate,
HXLoginViewControllerDelegate
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLogoutNotification object:nil];
    
    // Notify
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kClearNotifyNotifacation object:nil];
}

#pragma mark - Config Methods
- (void)loadConfigure {
    self.delegate = self;
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Socket
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidOpen:) name:WebSocketMgrNotificationDidOpen object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidFailWithError:) name:WebSocketMgrNotificationDidFailWithError object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidAutoReconnectFailed:) name:WebSocketMgrNotificationDidAutoReconnectFailed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketPushUnread:) name:WebSocketMgrNotificationPushUnread object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidCloseWithCode:) name:WebSocketMgrNotificationDidCloseWithCode object:nil];
    
    // Login
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoginSence) name:kLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutEventAction) name:kLogoutNotification object:nil];
    
    // Notify
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotificationBadge) name:kClearNotifyNotifacation object:nil];
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
            [self autoLogin];
            
            HXDiscoveryViewController *discoveryViewController = [((UINavigationController *)[self.viewControllers firstObject]).viewControllers firstObject];
            [discoveryViewController fetchShareList];
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
        [[HXUserSession share].user setNotifyAvatar:[notification userInfo][MiaAPIKey_Values][@"notifyUserpic"]];
        [[HXUserSession share].user setNotifyCount:notifyCount];

		[self updateNotificationBadge];
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

- (void)autoLogin {
    HXUserSession *userSession = [HXUserSession share];
    switch (userSession.userState) {
        case HXUserStateLogout: {
            return;
            break;
        }
        case HXUserStateLogin: {
            [MiaAPIHelper loginWithSession:userSession.user.uid
                                     token:userSession.user.token
                             completeBlock:
             ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
                 if (success) {
                     NSDictionary *data = userInfo[MiaAPIKey_Values];
                     HXUserModel *user = [HXUserModel mj_objectWithKeyValues:data];
                     [userSession updateUser:user];

					 [self updateNotificationBadge];
                 } else {
                     [[FileLog standard] log:@"autoLogin failed, logout"];
                     [userSession logout];
                 }
             } timeoutBlock:^(MiaRequestItem *requestItem) {
                 NSLog(@"audo login timeout!");
             }];
            break;
        }
    }
}

- (void)autoReconnect {
    // TODO auto reconnect
    [[WebSocketMgr standard] reconnect];
}

#pragma mark - Private Methods
- (void)showLoginSence {
    UINavigationController *loginNavigationController = [HXLoginViewController navigationControllerInstance];
    HXLoginViewController *loginViewController = loginNavigationController.viewControllers.firstObject;
    loginViewController.delegate = self;
    
    [self transitionAnimationOnView:loginViewController.view duration:0.4f type:kCATransitionMoveIn subtype:kCATransitionFromRight];
    [self.view addSubview:loginViewController.view];
    [self addChildViewController:loginViewController];
    
}

- (CATransition *)transitionAnimationOnView:(UIView *)view duration:(CFTimeInterval)duration type:(NSString *)type subtype:(NSString *)subtype {
    CATransition *animation = [CATransition animation];
    animation.duration = duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fillMode = kCAFillModeForwards;
    animation.type = type;
    animation.subtype = subtype;
    [view.layer addAnimation:animation forKey:@"animation"];
    
    return animation;
}

- (void)logoutEventAction {
    [self setSelectedIndex:0];
}

- (void)showNoNetworkView {
    [HXNoNetworkView showOnViewController:self show:nil play:nil];
}

- (UITabBarItem *)subViewControllerTabBarItem {
    return self.viewControllers[2].tabBarItem;
}

- (void)updateNotificationBadge {
	NSInteger notifyCount = [HXUserSession share].user.notifyCount;
	if (notifyCount > 0) {
		[self subViewControllerTabBarItem].badgeValue = @(notifyCount).stringValue;
	} else {
		[self subViewControllerTabBarItem].badgeValue = nil;
	}

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

#pragma mark - HXLoginViewControllerDelegate Methods
- (void)loginViewController:(HXLoginViewController *)loginViewController takeAction:(HXLoginViewControllerAction)action {
    [loginViewController.view removeFromSuperview];
    [loginViewController removeFromParentViewController];
    switch (action) {
        case HXLoginViewControllerActionDismiss: {
            [self transitionAnimationOnView:self.view duration:0.5f type:kCATransitionReveal subtype:kCATransitionFromLeft];
            break;
        }
        case HXLoginViewControllerActionLoginSuccess: {
            HXDiscoveryViewController *discoveryViewController = [((UINavigationController *)[self.viewControllers firstObject]).viewControllers firstObject];
            [discoveryViewController refreshShareItem];
            [self updateNotificationBadge];
            [self transitionAnimationOnView:self.view duration:0.5f type:kCATransitionReveal subtype:kCATransitionFromLeft];
            break;
        }
    }
}

@end
