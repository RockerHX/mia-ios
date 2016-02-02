//
//  HXHomePageViewController.m
//  mia
//
//  Created by miaios on 15/10/9.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXHomePageViewController.h"
#import "HXRadioViewController.h"
#import "HXBubbleView.h"
#import "HXHomePageWaveView.h"
#import "HXInfectUserView.h"
#import "UserSession.h"
#import "HXLoginViewController.h"
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
#import "ShareItem.h"
#import "UpdateHelper.h"
#import "FavoriteMgr.h"
#import "HXInfectUserItemView.h"
#import "HXFeedBackViewController.h"
#import "FileLog.h"
#import "HXProfileViewController.h"

static NSString *kAlertMsgNoNetwork     = @"没有网络连接，请稍候重试";
static NSString *kGuideViewShowKey      = @"kGuideViewShow-v";

@interface HXHomePageViewController () <
HXBubbleViewDelegate,
HXRadioViewControllerDelegate
>
@end

@implementation HXHomePageViewController {
    BOOL _toLogin;
    BOOL _animating;                // 动画执行标识
    CGFloat _fishViewCenterY;       // 小鱼中心高度位置
    NSTimer *_timer;                // 定时器，用户在妙推动作时默认不评论定时执行结束动画
    ShareItem *_playItem;
    
}

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

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _fishViewCenterY = _fishView.center.y;      // 记录小鱼中心点高度，用于控制小鱼拖动
}

- (void)dealloc {
    // 通知关闭
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidOpen object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidFailWithError object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidAutoReconnectFailed object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationPushUnread object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidCloseWithCode object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNeedLoginNotification object:nil];
    
    [[UserSession standard] removeObserver:self forKeyPath:UserSessionKey_Avatar context:nil];
    [[UserSession standard] removeObserver:self forKeyPath:UserSessionKey_LoginState context:nil];
	[[UserSession standard] removeObserver:self forKeyPath:UserSessionKey_NotifyCount context:nil];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentLoginViewController:) name:kNeedLoginNotification object:nil];
    
    [[UserSession standard] addObserver:self forKeyPath:UserSessionKey_Avatar options:NSKeyValueObservingOptionNew context:nil];
    [[UserSession standard] addObserver:self forKeyPath:UserSessionKey_LoginState options:NSKeyValueObservingOptionNew context:nil];
	[[UserSession standard] addObserver:self forKeyPath:UserSessionKey_NotifyCount options:NSKeyValueObservingOptionNew context:nil];

    // 初始化小鱼动画帧
    NSMutableArray *fishIcons = @[].mutableCopy;
    for (NSInteger index = 1; index <= 34; index ++) {
        [fishIcons addObject:[UIImage imageNamed:[NSString stringWithFormat:@"fish-%zd", index]]];
    }
    _fishView.animationImages = fishIcons;
    _fishView.animationDuration = 1.5f;
    
    // 处理手势响应先后顺序
    [_swipeGesture requireGestureRecognizerToFail:_panGesture];
}

- (void)viewConfig {
    _shareButton.backgroundColor = [UIColor whiteColor];
    _profileButton.layer.borderWidth = 0.5f;
    _profileButton.layer.borderColor = UIColorFromHex(@"A2A2A2", 1.0f).CGColor;
    _profileButton.layer.cornerRadius = _profileButton.frame.size.height/2;
	[_profileButton setImage:nil forState:UIControlStateNormal];
	[_profileButton setBackgroundImage:[UIImage imageNamed:@"HP-InfectUserDefaultHeader"] forState:UIControlStateNormal];

    _shareButton.backgroundColor = [UIColor whiteColor];
    _shareButton.layer.cornerRadius = _profileButton.frame.size.height/2;
    
    _pushPromptLabel.alpha = 0.0f;
    _infectCountRightPromptLabel.alpha = 0.0f;
    
    [self hanleUnderiPhone6Size];
    [self animationViewConfig];
}

- (void)hanleUnderiPhone6Size {
    if ([HXVersion isIPhone5SPrior]) {
        _fishBottomConstraint.constant = _fishBottomConstraint.constant - 5.0f;
    }
}

- (void)animationViewConfig {
    // 配置气泡的比例和放大锚点；配置妙推用户视图的缩放比例
    _bubbleView.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
    _bubbleView.layer.anchorPoint = CGPointMake(0.4f, 1.0f);
    _infectUserView.transform = CGAffineTransformMakeScale(0.84f, 0.84f);
    
    // 配置提示条，设置为隐藏
    _infectCountPromptLabel.alpha = 0.0f;
}

- (void)initLocationMgr {
	[[LocationMgr standard] initLocationMgr];
	[[LocationMgr standard] startUpdatingLocationWithOnceBlock:nil];
}

#pragma mark - Notification
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	//	NSLog(@"keyPath = %@, change = %@, context = %s", keyPath, change, (char *)context);
	if ([keyPath isEqualToString:UserSessionKey_Avatar]) {
		NSInteger unreadCount = [[UserSession standard] notifyCnt];
		[self updateProfileButtonWithUnreadCount:unreadCount];
    } else if ([keyPath isEqualToString:UserSessionKey_LoginState]) {
		if ([UserSession standard].state) {
            // 更新单条分享的信息
            [self getShareItem];
        } else {
            [_radioViewController cleanShareListUserState];
            [self shouldDisplayInfectUsers:_playItem];
        }
	} else if ([keyPath isEqualToString:UserSessionKey_NotifyCount]) {
		NSInteger notifyCount = [change[NSKeyValueChangeNewKey] integerValue];
		[self updateProfileButtonWithUnreadCount:notifyCount];
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
		NSInteger notifyCount = [[notification userInfo][MiaAPIKey_Values][@"notifyCnt"] integerValue];
		[[UserSession standard] setNotifyUserpic:[notification userInfo][MiaAPIKey_Values][@"notifyUserpic"]];
		[[UserSession standard] setNotifyCnt:notifyCount];
	} else {
		NSLog(@"notify count parse failed! error:%@", [notification userInfo][MiaAPIKey_Values][MiaAPIKey_Error]);
	}
}

- (void)notificationWebSocketDidCloseWithCode:(NSNotification *)notification {
	NSLog(@"Connection Closed! (see logs)");
}

#pragma mark - Event Response
- (IBAction)profileButtonPressed {
    // 用户按钮点击事件，未登录显示登录页面，已登录显示用户信息页面
    if ([[UserSession standard] isLogined]) {
        [self showProfileWithUID:[UserSession standard].uid type:HXProfileTypeHost];
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

static CGFloat OffsetHeightThreshold = 160.0f;  // 用户拖动手势触发动画阀值
- (IBAction)gestureEvent:(UIGestureRecognizer *)gesture {
    if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
        // 拖动手势
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gesture;
        switch (panGesture.state) {
            // 1.手势开始，小鱼游动
            case UIGestureRecognizerStateBegan: {
                [_fishView startAnimating];
                break;
            }
            // 拖动手势位移，配合拖动阀值移动小鱼并出发动画
            case UIGestureRecognizerStateChanged: {
                if (!_playItem.isInfected || ![UserSession standard].state) {
                    CGFloat offsetHeight = [panGesture translationInView:self.view].y;
                    if (offsetHeight < 0.0f) {
                        CGFloat fabsOffsetHeightY = fabs(offsetHeight);
                        if (fabsOffsetHeightY >= OffsetHeightThreshold) {
                            [self startAnimation];
                        } else {
                            CGFloat panPercent = (fabsOffsetHeightY/OffsetHeightThreshold);
                            _fishView.center = CGPointMake(_fishView.center.x, _fishViewCenterY - 30.0f*panPercent);
                        }
                    }
                }
                break;
            }
            // 手势结束，失败，取消，停止小鱼游动，小鱼弹回，用于用户取消操作
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateFailed:
            case UIGestureRecognizerStateCancelled: {
                if (!_playItem.isInfected) {
                    if (!_animating) {
                        __weak __typeof__(self)weakSelf = self;
                        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                            __strong __typeof__(self)strongSelf = weakSelf;
                            strongSelf.fishView.center = CGPointMake(strongSelf.fishView.center.x, _fishViewCenterY);
                        } completion:nil];
                    }
                }
                break;
            }
                
            default:
                break;
        }
    } else if ([gesture isKindOfClass:[UISwipeGestureRecognizer class]]) {
        // 滑动手势
        UISwipeGestureRecognizer *swipeGesture = (UISwipeGestureRecognizer *)gesture;
        switch (swipeGesture.direction) {
            case UISwipeGestureRecognizerDirectionUp: {
                if (!_playItem.isInfected) {
                    [self startAnimation];
                }
                break;
            }
            default:
                break;
        }
    }
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

- (void)startAnimation {
    if (!_animating) {
        _animating = YES;
        if ([[UserSession standard] isLogined]) {
            [self infectShare];
        }
        [self startWaveAnimation];
        [self startPopFishAnimation];
    }
}

- (void)stopAnimation {
    _animating = NO;
    
    [self getShareItem];
}

- (void)showInfectUsers:(NSArray *)infectUsers {
    [_infectUserView removeAllItem];
    
    NSInteger infectUserCount = infectUsers.count;
    if (infectUserCount) {
        NSMutableArray *itmes = [NSMutableArray arrayWithCapacity:infectUsers.count];
        for (InfectUserItem *item in infectUsers) {
            [itmes addObject:[NSURL URLWithString:item.avatar]];
        }
        [_infectUserView showWithItems:itmes];
        __weak __typeof__(self)weakSelf = self;
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            __strong __typeof__(self)strongSelf = weakSelf;
            [strongSelf.infectUserView refresh];
        } completion:^(BOOL finished) {
            __strong __typeof__(self)strongSelf = weakSelf;
            // 妙推用户头像跳动动画
            [strongSelf.infectUserView refreshItemWithAnimation];
        }];
    }
    
    [self showPushPromptLabel:!infectUserCount];
}

- (void)showPushPromptLabel:(BOOL)show {
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.4f animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf.pushPromptLabel.alpha = show ? 1.0f : 0.0f;
    }];
}

- (void)showinfectCountRightPromptLabel:(BOOL)show withCount:(NSInteger)count {
    if (count) {
        _infectCountRightPromptLabel.text = [NSString stringWithFormat:@"%@人妙推", @(count)];
    }
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.3f animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf.infectCountRightPromptLabel.alpha = show ? 1.0f : 0.0f;
    }];
}

- (void)addPushUserHeader {
    [self updatePromptLabel];
    // 妙推用户头像添加以及动画
    [_infectUserView addItemAtFirstIndex:[NSURL URLWithString:[[UserSession standard] avatar]]];
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf.infectUserView refresh];
    } completion:^(BOOL finished) {
        __strong __typeof__(self)strongSelf = weakSelf;
        // 妙推用户头像跳动动画
        [strongSelf.infectUserView refreshItemWithAnimation];
        // 妙推提示条显示动画
        [strongSelf startPushPromptLabelAnimation];
    }];
}

- (void)updatePromptLabel {
    NSInteger count = _playItem.infectTotal;
    NSString *prompt = [NSString stringWithFormat:@"%@人妙推", @(count)];
    _infectCountPromptLabel.text = prompt;
}

- (void)reset {
    [_fishView stopAnimating];
    [_bubbleView reset];
    [_waveView reset];
    
    // 重新布局
    _fishBottomConstraint.constant = [HXVersion isIPhone5SPrior] ? 15.0f : 20.0f;
    _headerViewBottomConstraint.constant = 2.0f;
    _fishView.alpha = 1.0f;
    _bubbleView.alpha = 1.0f;
    [self animationViewConfig];
    _fishView.transform = CGAffineTransformIdentity;
    [self.view layoutIfNeeded];
}

- (void)executeTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.4f target:self selector:@selector(startFinishedAnimation) userInfo:nil repeats:NO];
}

- (void)startPushMusicRequsetWithComment:(NSString *)comment {
    comment = comment ?: @"";
    // 用户按钮点击事件，未登录显示登录页面，已登录显示用户信息页面
    if ([[UserSession standard] isLogined]) {
        [MiaAPIHelper postCommentWithShareID:_playItem.sID
                                     comment:comment
								   commentID:nil
                               completeBlock:
		 ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
			 if (success) {
				 [HXAlertBanner showWithMessage:@"评论成功" tap:nil];
			 } else {
				 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
				 [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
			 }
		 } timeoutBlock:^(MiaRequestItem *requestItem) {
			 [HXAlertBanner showWithMessage:@"提交评论失败，网络请求超时" tap:nil];
		 }];
		[self startFinishedAnimation];
    } else {
        [self presentLoginViewController:nil];
    }
}

- (void)updateProfileButtonWithUnreadCount:(NSInteger)unreadCommentCount {
    if (unreadCommentCount <= 0) {
        _profileButton.layer.borderWidth = 0.5f;
		[_profileButton setTitle:@"" forState:UIControlStateNormal];

		if ([NSString isNull:[UserSession standard].avatar]) {
			[_profileButton setBackgroundImage:[UIImage imageNamed:@"HP-InfectUserDefaultHeader"] forState:UIControlStateNormal];
		} else {
			[_profileButton sd_setBackgroundImageWithURL:[NSURL URLWithString:[UserSession standard].avatar]
												forState:UIControlStateNormal
										placeholderImage:[UIImage imageNamed:@"HP-InfectUserDefaultHeader"]
												 options:SDWebImageRetryFailed];
		}
	} else {
        _profileButton.layer.borderWidth = 0.0f;
		[_profileButton setBackgroundImage:[UIImage createImageWithColor:UIColorFromHex(@"0BDEBC", 1.0)] forState:UIControlStateNormal];
		[_profileButton setTitle:[NSString stringWithFormat:@"%ld", (long)unreadCommentCount] forState:UIControlStateNormal];
	}
}

- (void)checkUpdate {
	UpdateHelper *aUpdateHelper = [[UpdateHelper alloc] init];
	[aUpdateHelper checkNow];
}

- (BOOL)autoLogin {
	NSString *uid = [UserDefaultsUtils valueWithKey:UserDefaultsKey_SessionUID];
	NSString *token = [UserDefaultsUtils valueWithKey:UserDefaultsKey_SessionToken];
	if ([NSString isNull:uid] || [NSString isNull:token]) {
		return NO;
	}
    
    [MiaAPIHelper loginWithSession:uid
							 token:token
					 completeBlock:
     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
         if (success) {
             [[UserSession standard] setUid:[NSString stringWithFormat:@"%@", userInfo[MiaAPIKey_Values][@"uid"]]];
             [[UserSession standard] setNick:userInfo[MiaAPIKey_Values][@"nick"]];
             [[UserSession standard] setUtype:userInfo[MiaAPIKey_Values][@"utype"]];
			 [[UserSession standard] setNotifyCnt:[userInfo[MiaAPIKey_Values][@"notifyCnt"] integerValue]];
			 [[UserSession standard] setNotifyUserpic:userInfo[MiaAPIKey_Values][@"notifyUserpic"]];

             NSString *avatarUrl = userInfo[MiaAPIKey_Values][@"userpic"];
             NSString *avatarUrlWithTime = [NSString stringWithFormat:@"%@?t=%ld", avatarUrl, (long)[[NSDate date] timeIntervalSince1970]];
             [[UserSession standard] setAvatar:avatarUrlWithTime];
             [UserDefaultsUtils saveValue:userInfo[MiaAPIKey_Values][@"uid"] forKey:UserDefaultsKey_UID];
             [UserDefaultsUtils saveValue:userInfo[MiaAPIKey_Values][@"nick"] forKey:UserDefaultsKey_Nick];
             [UserSession standard].state = UserSessionLoginStateLogin;
		 } else {
			 [[FileLog standard] log:@"autoLogin failed, logout"];
			 [[UserSession standard] logout];
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

- (void)infectShare {
    if (!_playItem.isInfected) {
        _playItem.isInfected = YES;
        _playItem.infectTotal += 1;
        [self showinfectCountRightPromptLabel:NO withCount:_playItem.infectTotal];
        
        // 传播出去不需要切换歌曲，需要记录下传播的状态和上报服务器
        [MiaAPIHelper InfectMusicWithLatitude:[[LocationMgr standard] currentCoordinate].latitude
                                    longitude:[[LocationMgr standard] currentCoordinate].longitude
                                      address:[[LocationMgr standard] currentAddress]
                                         spID:_playItem.spID
                                completeBlock:
         ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
             if (success) {

				 int isInfected = [userInfo[MiaAPIKey_Values][@"data"][@"isInfected"] intValue];
				 int infectTotal = [userInfo[MiaAPIKey_Values][@"data"][@"infectTotal"] intValue];
				 NSArray *infectArray = userInfo[MiaAPIKey_Values][@"data"][@"infectList"];
				 NSString *spID = [userInfo[MiaAPIKey_Values][@"data"][@"spID"] stringValue];

				 if ([spID isEqualToString:_playItem.spID]) {
					 _playItem.infectTotal = infectTotal;
					 [_playItem parseInfectUsersFromJsonArray:infectArray];
					 _playItem.isInfected = isInfected;
				 }
             } else {
                 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
                 [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
             }
         } timeoutBlock:^(MiaRequestItem *requestItem) {
             _playItem.isInfected = YES;
             [HXAlertBanner showWithMessage:@"妙推失败，网络请求超时" tap:nil];
         }];
    }
}

- (void)showNoNetworkView {
	[HXNoNetworkView showOnViewController:self show:nil play:nil];
}

- (void)cancelLoginOperate {
    [self startWaveMoveUpAnimation];
    [self startHeaderViewPopBackAnimation];
    [self startFinshAndBubbleHiddenAnimation];
}

- (void)displayWithInfectState:(BOOL)infected {
    BOOL logined = [[UserSession standard] isLogined];
    if (logined) {
        _infectCountPromptLabel.alpha = 0.0f;
        _bubbleView.hidden = infected;
    }
    _fishView.hidden = infected;
    
    if (infected && logined) {
        [self startInfectedStateAnimation];
    } else {
        [self startUnInfectedStateAnimation];
    }
}

- (void)presentLoginViewController:(void(^)(BOOL success))success {
    _toLogin = YES;
    UINavigationController *loginNavigationController = [HXLoginViewController navigationControllerInstance];
    __weak __typeof__(self)weakSelf = self;
    [self presentViewController:loginNavigationController animated:YES completion:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf->_toLogin = NO;
    }];
}

- (void)viewTapedCanShowMusicDetail:(BOOL)show {
    [self.view endEditing:YES];
    if (_animating) {
        if (![[UserSession standard] isLogined]) {
            [self cancelLoginOperate];
        } else {
            [self startFinishedAnimation];
        }
    } else {
        if (show) {
            [self stopAnimation];
            HXMusicDetailViewController *musicDetailViewController = [HXMusicDetailViewController instance];
            musicDetailViewController.playItem = _playItem;
            [self.navigationController pushViewController:musicDetailViewController animated:YES];
        }
    }
}

- (void)showProfileWithUID:(NSString *)uid type:(HXProfileType)type {
    HXProfileViewController *profileViewController = [HXProfileViewController instance];
    profileViewController.type = type;
    profileViewController.uid = uid;
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)getShareItem {
    [MiaAPIHelper getShareById:_playItem.sID
                          spID:_playItem.spID
                 completeBlock:
     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
         if (success) {
             NSString *sID = userInfo[MiaAPIKey_Values][@"data"][@"sID"];
             id start = userInfo[MiaAPIKey_Values][@"data"][@"star"];
             id cComm = userInfo[MiaAPIKey_Values][@"data"][@"cComm"];
             id cView = userInfo[MiaAPIKey_Values][@"data"][@"cView"];
             id infectTotal = userInfo[MiaAPIKey_Values][@"data"][@"infectTotal"];
             int isInfected = [userInfo[MiaAPIKey_Values][@"data"][@"isInfected"] intValue];
             NSArray *infectArray = userInfo[MiaAPIKey_Values][@"data"][@"infectList"];
             NSArray *flyArray = userInfo[MiaAPIKey_Values][@"data"][@"flyList"];
             
             if ([sID isEqualToString:_playItem.sID]) {
                 _playItem.isInfected = isInfected;
                 _playItem.cComm = [cComm intValue];
                 _playItem.cView = [cView intValue];
                 _playItem.favorite = [start intValue];
                 _playItem.infectTotal = [infectTotal intValue];
                 
                 NSDictionary *shareUserDict = userInfo[MiaAPIKey_Values][@"data"][@"shareUser"];
                 NSDictionary *spaceUserDict = userInfo[MiaAPIKey_Values][@"data"][@"spaceUser"];
                 _playItem.shareUser.follow = [shareUserDict[@"follow"] boolValue];
                 _playItem.spaceUser.follow = [spaceUserDict[@"follow"] boolValue];
                 
                 [_playItem parseInfectUsersFromJsonArray:infectArray];
                 [_playItem parseFlyCommentsFromJsonArray:flyArray];
             }
             [self shouldDisplayInfectUsers:_playItem];
         } else {
             NSLog(@"getShareById failed");
         }
     } timeoutBlock:^(MiaRequestItem *requestItem) {
         NSLog(@"getShareById timeout");
     }];
}

#pragma mark - Animation
- (void)startWaveAnimation {
    [_waveView.waveView startAnimating];
}

- (void)stopWaveAnimation {
    [_waveView.waveView stopAnimating];
}

// 小鱼跳出动画
- (void)startPopFishAnimation {
    _fishBottomConstraint.constant = self.view.frame.size.height/2 - ([HXVersion isIPhone5SPrior] ? 110.0f : 140.0f);
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf.fishView.transform = CGAffineTransformIdentity;
        [strongSelf.view layoutIfNeeded];
    } completion:nil];
    
    [self startBubbleScaleAnimation];
    [self startWaveMoveDownAnimation];
    [self startHeaderViewPopAnimationAddUser:YES];
}

// 气泡弹出动画
- (void)startBubbleScaleAnimation {
    [_bubbleView showWithLogin:[[UserSession standard] isLogined]];
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.5f delay:0.1f usingSpringWithDamping:0.7f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf.bubbleView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if ([[UserSession standard] isLogined]) {
            __strong __typeof__(self)strongSelf = weakSelf;
            [strongSelf executeTimer];
        }
    }];
}

// 波浪退出动画
- (void)startWaveMoveDownAnimation {
    [_waveView waveMoveDownAnimation:nil];
}

// 波浪升起动画
- (void)startWaveMoveUpAnimation {
    __weak __typeof__(self)weakSelf = self;
    [_waveView waveMoveUpAnimation:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf reset];
        [strongSelf.fishView startAnimating];
    }];
}

- (void)startFinshAndBubbleHiddenAnimation {
    [_fishView stopAnimating];
    
    [UIView animateWithDuration:0.4f animations:^{
        _fishView.alpha = 0.0f;
        _bubbleView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        _animating = NO;
        _fishBottomConstraint.constant = 20.0f;
    }];
}

// 头像弹出动画
- (void)startHeaderViewPopAnimationAddUser:(BOOL)add {
    _headerViewBottomConstraint.constant = 40.0f;
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:1.0f delay:0.4f usingSpringWithDamping:0.5f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveEaseIn animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf.infectUserView.transform = CGAffineTransformIdentity;
        [strongSelf.infectUserView layoutIfNeeded];
    } completion:^(BOOL finished) {
        __strong __typeof__(self)strongSelf = weakSelf;
        if (!add) {
            [strongSelf updatePromptLabel];
            [strongSelf startPushPromptLabelAnimation];
        }
    }];
    if ([[UserSession standard] isLogined] && add) {
        [self addPushUserHeader];
    }
}

- (void)startPushPromptLabelAnimation {
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.3f animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf.infectCountPromptLabel.alpha = 1.0f;
    } completion:nil];
}

// 头像收回动画
- (void)startHeaderViewPopBackAnimation {
    _headerViewBottomConstraint.constant = 2.0f;
    [UIView animateWithDuration:1.0f delay:0.0f usingSpringWithDamping:0.5f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveEaseIn animations:^{
        _infectUserView.transform = CGAffineTransformMakeScale(0.84f, 0.84f);
        [_infectUserView layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (_animating) {
            [self stopAnimation];
        }
    }];
}

// 妙推完成，结束动画
- (void)startFinishedAnimation {
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.8f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        
        // 小鱼转动动画
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformScale(transform, 0.2f, 0.2f);
        transform = CGAffineTransformRotate(transform, -M_PI * 3/4);
        strongSelf.fishView.transform = transform;
        strongSelf.fishView.alpha = 0.0f;
        
        // 气泡缩小动画
        strongSelf.bubbleView.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
        strongSelf.bubbleView.alpha = 0.0f;
        
        // 小鱼，气泡移动结束动画
        UIView *header = strongSelf.infectUserView.stacView.arrangedSubviews.firstObject;
        CGPoint endPont = CGPointMake(strongSelf.infectUserView.frame.origin.x +  header.center.x, strongSelf.infectUserView.frame.origin.y);
        strongSelf.fishView.center = endPont;
        strongSelf.bubbleView.center = endPont;
    } completion:^(BOOL finished) {
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf stopAnimation];
    }];
}

- (void)startInfectedStateAnimation {
    [self startWaveMoveDownAnimation];
    [self startHeaderViewPopAnimationAddUser:NO];
}

- (void)startUnInfectedStateAnimation {
    [self startWaveMoveUpAnimation];
    [self startHeaderViewPopBackAnimation];
}

#pragma mark - HXBubbleViewDelegate Methods
- (void)bubbleViewStartEdit:(HXBubbleView *)bubbleView {
    // 产品设计内容，用于一旦编辑气泡内容，必须关闭小鱼洄游动画定时器
    [_timer invalidate];
}

- (void)bubbleView:(HXBubbleView *)bubbleView shouldSendComment:(NSString *)comment {
    // 用户触发妙推评论发送之后关闭键盘并执行妙推评论数据请求
    [self.view endEditing:YES];
    [self startPushMusicRequsetWithComment:comment];
}

- (void)bubbleViewShouldLogin:(HXBubbleView *)bubbleView {
    [self presentLoginViewController:nil];
    [self cancelLoginOperate];
}

#pragma mark - LoginViewControllerDelegate
- (void)loginViewControllerDismissWithoutLogin {
	if (![[WebSocketMgr standard] isOpen]) {
		[self showNoNetworkView];
	}
}

- (void)loginViewControllerDidSuccess {
    if ([[UserSession standard] isLogined]) {
        NSInteger unreadCommentCount = [[UserSession standard] notifyCnt];
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
        [MiaAPIHelper favoriteMusicWithShareID:_playItem.sID
                                    isFavorite:!_playItem.favorite
                                 completeBlock:
         ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
             if (success) {
                 id act = userInfo[MiaAPIKey_Values][@"act"];
                 id sID = userInfo[MiaAPIKey_Values][@"id"];
                 BOOL favorite = [act intValue];
                 if ([_playItem.sID integerValue] == [sID intValue]) {
                     _playItem.favorite = favorite;
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

- (void)raidoViewDidTaped {
    [self viewTapedCanShowMusicDetail:NO];
}

- (void)userWouldLikeSeeSharerWithItem:(ShareItem *)item {
    HXProfileType type;
    NSString *sharerID = item.shareUser.uid;
    NSString *userID = [UserSession standard].uid;
    if (![sharerID isEqualToString:userID]) {
        type = HXProfileTypeGuest;
        userID = sharerID;
    } else {
        type = HXProfileTypeHost;
    }
    [self showProfileWithUID:userID type:type];
}

- (void)userWouldLikeSeeInfecterWithItem:(ShareItem *)item {
    HXProfileType type;
    NSString *infecterID = item.spaceUser.uid;
    NSString *userID = [UserSession standard].uid;
    if (![infecterID isEqualToString:userID]) {
        type = HXProfileTypeGuest;
        userID = infecterID;
    } else {
        type = HXProfileTypeHost;
    }
    [self showProfileWithUID:userID type:type];
}

- (void)userWouldLikeSeeShareDetialWithItem:(ShareItem *)item {
    [self viewTapedCanShowMusicDetail:YES];
}

- (void)shouldDisplayInfectUsers:(ShareItem *)item {
    _playItem = item;
    BOOL isInfected = item.isInfected;
    NSArray *infectUsers = item.infectUsers;
    [self showInfectUsers:infectUsers];
    [self displayWithInfectState:isInfected];
    
    NSInteger infectUsersCount = infectUsers.count;
    [self showinfectCountRightPromptLabel:(infectUsersCount && !isInfected) withCount:item.infectTotal];
}

@end
