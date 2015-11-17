//
//  HXHomePageViewController.m
//  mia
//
//  Created by miaios on 15/10/9.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXHomePageViewController.h"
#import "HXNavigationController.h"
#import "HXRadioViewController.h"
#import "UserSession.h"
#import "LoginViewController.h"
#import "MyProfileViewController.h"
#import "HXShareViewController.h"
#import "WebSocketMgr.h"
#import "NSString+IsNull.h"
#import "UIButton+WebCache.h"
#import "MiaAPIHelper.h"
#import "UserDefaultsUtils.h"
#import "HXNoNetworkView.h"
#import "InfectUserItem.h"
#import "UIImageView+WebCache.h"
#import "LocationMgr.h"
#import "HXAlertBanner.h"
#import "HXGuideView.h"
#import "HXVersion.h"
#import "HXMusicDetailViewController.h"
#import "UIImage+ColorToImage.h"
#import "GuestProfileViewController.h"
#import "ShareItem.h"
#import "UpdateHelper.h"
#import "FavoriteMgr.h"
#import "HXFeedBackViewController.h"

static NSString *kAlertMsgNoNetwork     = @"没有网络连接，请稍候重试";
static NSString *kGuideViewShowKey      = @"kGuideViewShow-v";

@interface HXHomePageViewController () <LoginViewControllerDelegate , MyProfileViewControllerDelegate , HXRadioViewControllerDelegate> {
    BOOL _toLogin;
    ShareItem *_playItem;
}

@end

@implementation HXHomePageViewController

#pragma mark - View Controller Life Cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:_toLogin animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initConfig];
    [self viewConfig];
    
    if ([self needShowGuideView]) {
        __weak __typeof__(self)weakSelf = self;
        [HXGuideView showGuide:^{
            __strong __typeof__(self)strongSelf = weakSelf;
            [strongSelf startLoadMusic];
            [strongSelf guideViewShowed];
        }];
    } else {
        [self startLoadMusic];
    }
}

- (void)dealloc {
    // 通知关闭
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidOpen object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidFailWithError object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidAutoReconnectFailed object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationPushUnread object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidCloseWithCode object:nil];
    
    [[UserSession standard] removeObserver:self forKeyPath:UserSessionKey_Avatar context:nil];
    [[UserSession standard] removeObserver:self forKeyPath:UserSessionKey_LoginState context:nil];
}

#pragma mark - Prepare
static NSString *HomePageContainerIdentifier = @"HomePageContainerIdentifier";
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:HomePageContainerIdentifier]) {
        _radioViewController = segue.destinationViewController;
		_radioViewController.delegate = self;
    }
}

#pragma mark - Config Methods
- (void)initConfig {
    kGuideViewShowKey = [kGuideViewShowKey stringByAppendingFormat:@"%@.%@", [HXVersion appVersion], [HXVersion appBuildVersion]];
    // 通知注册
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidOpen:) name:WebSocketMgrNotificationDidOpen object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidFailWithError:) name:WebSocketMgrNotificationDidFailWithError object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidAutoReconnectFailed:) name:WebSocketMgrNotificationDidAutoReconnectFailed object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketPushUnread:) name:WebSocketMgrNotificationPushUnread object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidCloseWithCode:) name:WebSocketMgrNotificationDidCloseWithCode object:nil];
    [[UserSession standard] addObserver:self forKeyPath:UserSessionKey_Avatar options:NSKeyValueObservingOptionNew context:nil];
    [[UserSession standard] addObserver:self forKeyPath:UserSessionKey_LoginState options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewConfig {
    _shareButton.backgroundColor = [UIColor whiteColor];
    _profileButton.layer.borderWidth = 0.5f;
    _profileButton.layer.borderColor = UIColorFromHex(@"A2A2A2", 1.0f).CGColor;
    _profileButton.layer.cornerRadius = _profileButton.frame.size.height/2;
    
    _shareButton.backgroundColor = [UIColor whiteColor];
    _shareButton.layer.cornerRadius = _profileButton.frame.size.height/2;
}

- (void)initLocationMgr {
	[[LocationMgr standard] initLocationMgr];
	[[LocationMgr standard] startUpdatingLocationWithOnceBlock:nil];
}

#pragma mark - Notification
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	//	NSLog(@"keyPath = %@, change = %@, context = %s", keyPath, change, (char *)context);
	if ([keyPath isEqualToString:UserSessionKey_Avatar]) {
		NSString *newAvatarUrl = change[NSKeyValueChangeNewKey];
		if ([NSString isNull:newAvatarUrl]) {
			[_profileButton setImage:[UIImage imageNamed:@"HP-InfectUserDefaultHeader"] forState:UIControlStateNormal];
        } else {
			int unreadCount = [[[UserSession standard] unreadCommCnt] intValue];
			[self updateProfileButtonWithUnreadCount:unreadCount];
		}
    } else if ([keyPath isEqualToString:UserSessionKey_LoginState]) {
		if ([UserSession standard].state) {
            __weak __typeof__(self)weakSelf = self;
            // 更新单条分享的信息
            [MiaAPIHelper getShareById:_playItem.sID completeBlock:
             ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
                 __strong __typeof__(self)strongSelf = weakSelf;
                 if (success) {
                     NSString *sID = userInfo[MiaAPIKey_Values][@"data"][@"sID"];
                     id start = userInfo[MiaAPIKey_Values][@"data"][@"star"];
                     id cComm = userInfo[MiaAPIKey_Values][@"data"][@"cComm"];
                     id cView = userInfo[MiaAPIKey_Values][@"data"][@"cView"];
                     id infectTotal = userInfo[MiaAPIKey_Values][@"data"][@"infectTotal"];
                     int isInfected = [userInfo[MiaAPIKey_Values][@"data"][@"isInfected"] intValue];
                     NSArray *infectArray = userInfo[MiaAPIKey_Values][@"data"][@"infectList"];
                     
                     if ([sID isEqualToString:strongSelf->_playItem.sID]) {
                         strongSelf->_playItem.isInfected = isInfected;
                         strongSelf->_playItem.cComm = [cComm intValue];
                         strongSelf->_playItem.cView = [cView intValue];
                         strongSelf->_playItem.favorite = [start intValue];
                         strongSelf->_playItem.infectTotal = [infectTotal intValue];
                         [strongSelf->_playItem parseInfectUsersFromJsonArray:infectArray];
                     }
                     [strongSelf shouldDisplayInfectUsers:_playItem];
                 } else {
                     NSLog(@"getShareById failed");
                 }
             } timeoutBlock:^(MiaRequestItem *requestItem) {
                 NSLog(@"getShareById timeout");
             }];
        } else {
            [_radioViewController cleanShareListUserState];
            [self shouldDisplayInfectUsers:_playItem];
        }
    }
}

- (void)notificationWebSocketDidOpen:(NSNotification *)notification {
	[HXNoNetworkView hidden];
	[MiaAPIHelper sendUUIDWithCompleteBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
		if (success) {
			[self checkUpdate];
			if (![self autoLogin]) {
				[_radioViewController loadShareList];
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
		[self updateProfileButtonWithUnreadCount:[[notification userInfo][MiaAPIKey_Values][@"num"] intValue]];
	} else {
		NSLog(@"unread comment failed! error:%@", [notification userInfo][MiaAPIKey_Values][MiaAPIKey_Error]);
	}
}

- (void)notificationWebSocketDidCloseWithCode:(NSNotification *)notification {
	NSLog(@"Connection Closed! (see logs)");
}

#pragma mark - Event Response
- (IBAction)profileButtonPressed {
    // 用户按钮点击事件，未登录显示登录页面，已登录显示用户信息页面
    if ([[UserSession standard] isLogined]) {
        MyProfileViewController *myProfileViewController = [[MyProfileViewController alloc] initWitUID:[[UserSession standard] uid]
                                                                                              nickName:[[UserSession standard] nick]];
        myProfileViewController.customDelegate = self;
        [self.navigationController pushViewController:myProfileViewController animated:YES];
	} else {
        [self presentLoginViewController:nil];
    }
}

- (IBAction)shareButtonPressed {
    // 音乐分享按钮点击事件，未登录显示登录页面，已登录显示音乐分享页面
    if ([[UserSession standard] isLogined]) {
        HXShareViewController *shareViewController = [HXShareViewController instance];
        [self.navigationController pushViewController:shareViewController animated:YES];
    } else {
        [self presentLoginViewController:nil];
    }
}

- (IBAction)feedBackButtonPressed {
    HXFeedBackViewController *feedBackViewController = [HXFeedBackViewController instance];
    [self.navigationController pushViewController:feedBackViewController animated:YES];
}

#pragma mark - Private Methods
- (BOOL)needShowGuideView {
    NSNumber *showed = [[NSUserDefaults standardUserDefaults] valueForKey:kGuideViewShowKey];
    return !showed.boolValue;
}

- (void)guideViewShowed {
    [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:kGuideViewShowKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)startLoadMusic {
    [[WebSocketMgr standard] watchNetworkStatus];
    [self initLocationMgr];
}

- (void)updateProfileButtonWithUnreadCount:(int)unreadCommentCount {
    if (unreadCommentCount <= 0) {
        _profileButton.layer.borderWidth = 0.5f;
        [_profileButton sd_setImageWithURL:[NSURL URLWithString:[[UserSession standard] avatar]]
                                  forState:UIControlStateNormal
                          placeholderImage:[UIImage imageNamed:@"HP-InfectUserDefaultHeader"]];
	} else {
        _profileButton.layer.borderWidth = 0.0f;
		[_profileButton setImage:nil forState:UIControlStateNormal];
		[_profileButton setBackgroundColor:UIColorFromHex(@"0BDEBC", 1.0)];
		[_profileButton setTitle:[NSString stringWithFormat:@"%d", unreadCommentCount] forState:UIControlStateNormal];
	}
}

- (void)checkUpdate {
	UpdateHelper *aUpdateHelper = [[UpdateHelper alloc] init];
	[aUpdateHelper checkNow];
}

- (BOOL)autoLogin {
	NSString *userName = [UserDefaultsUtils valueWithKey:UserDefaultsKey_UserName];
	NSString *passwordHash = [UserDefaultsUtils valueWithKey:UserDefaultsKey_PasswordHash];
	if ([NSString isNull:userName] || [NSString isNull:passwordHash]) {
		return NO;
	}
    
    [MiaAPIHelper loginWithPhoneNum:userName
                       passwordHash:passwordHash
                      completeBlock:
     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
         if (success) {
             [[UserSession standard] setUid:userInfo[MiaAPIKey_Values][@"uid"]];
             [[UserSession standard] setNick:userInfo[MiaAPIKey_Values][@"nick"]];
             [[UserSession standard] setUtype:userInfo[MiaAPIKey_Values][@"utype"]];
             [[UserSession standard] setUnreadCommCnt:userInfo[MiaAPIKey_Values][@"unreadCommCnt"]];

             NSString *avatarUrl = userInfo[MiaAPIKey_Values][@"userpic"];
             NSString *avatarUrlWithTime = [NSString stringWithFormat:@"%@?t=%ld", avatarUrl, (long)[[NSDate date] timeIntervalSince1970]];
             [[UserSession standard] setAvatar:avatarUrlWithTime];
             [UserDefaultsUtils saveValue:userInfo[MiaAPIKey_Values][@"uid"] forKey:UserDefaultsKey_UID];
             [UserDefaultsUtils saveValue:userInfo[MiaAPIKey_Values][@"nick"] forKey:UserDefaultsKey_Nick];
             [UserSession standard].state = UserSessionLoginStateLogin;
         }
         
         [_radioViewController loadShareList];
     } timeoutBlock:^(MiaRequestItem *requestItem) {
         NSLog(@"audo login timeout!");
         [_radioViewController loadShareList];
     }];
	return YES;
}

- (void)autoReconnect {
	// TODO auto reconnect
	[[WebSocketMgr standard] reconnect];
}

- (void)showOfflineProfileWithPlayFavorite:(BOOL)playFavorite {
    if ([[UserSession standard] isCachedLogin]) {
        MyProfileViewController *myProfileViewController = [[MyProfileViewController alloc] initWitUID:[[UserSession standard] uid]
                                                                                              nickName:[[UserSession standard] nick]];
        myProfileViewController.customDelegate = self;
        myProfileViewController.playFavoriteOnceTime = playFavorite;
        [self.navigationController pushViewController:myProfileViewController animated:playFavorite ? NO : YES];
    } else {
        [self presentLoginViewController:nil];
	}
}

- (void)showNoNetworkView {
	[HXNoNetworkView showOnViewController:self show:^{
		[self showOfflineProfileWithPlayFavorite:NO];
	} play:^{
		[self showOfflineProfileWithPlayFavorite:YES];
	}];
}

- (void)presentLoginViewController:(void(^)(BOOL success))success {
    _toLogin = YES;
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    loginViewController.customDelegate = self;
    [loginViewController loginSuccess:success];
    HXNavigationController *loginNavigationViewController = [[HXNavigationController alloc] initWithRootViewController:loginViewController];
    __weak __typeof__(self)weakSelf = self;
    [self presentViewController:loginNavigationViewController animated:YES completion:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf->_toLogin = NO;
    }];
}

#pragma mark - LoginViewControllerDelegate
- (void)loginViewControllerDismissWithoutLogin {
	if (![[WebSocketMgr standard] isOpen]) {
		[self showNoNetworkView];
	}
}

- (void)loginViewControllerDidSuccess {
    if ([[UserSession standard] isLogined]) {
        int unreadCommentCount = [[[UserSession standard] unreadCommCnt] intValue];
        [self updateProfileButtonWithUnreadCount:unreadCommentCount];
    }
}

#pragma mark - MyProfileViewControllerDelegate Methods
- (void)myProfileViewControllerWillDismiss {
	if (![[WebSocketMgr standard] isOpen]) {
		[self showNoNetworkView];
	}
}

- (void)myProfileViewControllerUpdateUnreadCount:(int)count {
	[self updateProfileButtonWithUnreadCount:count];
}

#pragma mark - HXRadioViewControllerDelegate Methods
- (void)userStartNeedLogin {
    [self presentLoginViewController:^(BOOL success) {
        __weak __typeof__(self)weakSelf = self;
        [MiaAPIHelper favoriteMusicWithShareID:_playItem.sID
                                    isFavorite:!_playItem.favorite
                                 completeBlock:
         ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
             __strong __typeof__(self)strongSelf = weakSelf;
             if (success) {
                 id act = userInfo[MiaAPIKey_Values][@"act"];
                 id sID = userInfo[MiaAPIKey_Values][@"id"];
                 BOOL favorite = [act intValue];
                 if ([strongSelf->_playItem.sID integerValue] == [sID intValue]) {
                     strongSelf->_playItem.favorite = favorite;
                 }
                 [HXAlertBanner showWithMessage:(favorite ? @"收藏成功" : @"取消收藏成功") tap:nil];
                 
                 // 收藏操作成功后同步下收藏列表并检查下载
                 [[FavoriteMgr standard] syncFavoriteList];
             } else {
                 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
                 [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
             }
         } timeoutBlock:^(MiaRequestItem *requestItem) {
             [HXAlertBanner showWithMessage:@"收藏失败，网络请求超时" tap:nil];
         }];
    }];
}

- (void)userWouldLikeSeeSharerWithItem:(ShareItem *)item {
	GuestProfileViewController *viewController = [[GuestProfileViewController alloc] initWitUID:item.uID nickName:item.sNick];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)shouldDisplayInfectUsers:(ShareItem *)item {
    _playItem = item;
//    BOOL isInfected = item.isInfected;
//    NSArray *infectUsers = item.infectUsers;
//    [self showInfectUsers:infectUsers];
//    [self displayWithInfectState:isInfected];
//    
//    NSInteger infectUsersCount = infectUsers.count;
//    [self showinfectCountRightPromptLabel:(infectUsersCount && !isInfected) withCount:item.infectTotal];
}

@end
