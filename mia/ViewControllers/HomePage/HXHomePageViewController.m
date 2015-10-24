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
#import "LoginViewController.h"
#import "ProfileViewController.h"
#import "ShareViewController.h"
#import "WebSocketMgr.h"
#import "NSString+IsNull.h"
#import "UIButton+WebCache.h"
#import "MiaAPIHelper.h"
#import "UserDefaultsUtils.h"
#import "HXNoNetworkView.h"
#import "InfectUserItem.h"
#import "UIImageView+WebCache.h"
#import "LocationMgr.h"
#import "DetailViewController.h"
#import "HXAlertBanner.h"
#import "HXGuideView.h"
#import "HXVersion.h"

static NSString *kAlertMsgNoNetwork     = @"没有网络连接，请稍候重试";
static NSString *kGuideViewShowKey      = @"kGuideViewShow-v";

@interface HXHomePageViewController () <LoginViewControllerDelegate, HXBubbleViewDelegate, ProfileViewControllerDelegate, HXRadioViewControllerDelegate> {
    BOOL    _animating;             // 动画执行标识
    CGFloat _fishViewCenterY;       // 小鱼中心高度位置
    NSTimer *_timer;                // 定时器，用户在妙推动作时默认不评论定时执行结束动画
    ShareItem *_playItem;

}

@end

@implementation HXHomePageViewController

#pragma mark - View Controller Life Cycle
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
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidReceiveMessage object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidCloseWithCode object:nil];

	[[UserSession standard] removeObserver:self forKeyPath:UserSessionKey_Avatar context:nil];
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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidReceiveMessage:) name:WebSocketMgrNotificationDidReceiveMessage object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidCloseWithCode:) name:WebSocketMgrNotificationDidCloseWithCode object:nil];
	[[UserSession standard] addObserver:self forKeyPath:UserSessionKey_Avatar options:NSKeyValueObservingOptionNew context:nil];

    // 初始化小鱼动画帧
    NSMutableArray *fishIcons = @[].mutableCopy;
    for (NSInteger index = 1; index <= 67; index ++) {
        [fishIcons addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%zd", index]]];
    }
    _fishView.animationImages = fishIcons;
    _fishView.animationDuration = 3.0f;         //profileButton 设置小鱼动画为20帧左右
    
    // 处理手势响应先后顺序
    [_swipeGesture requireGestureRecognizerToFail:_panGesture];
}

- (void)viewConfig {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    _shareButton.backgroundColor = [UIColor whiteColor];
    _profileButton.layer.borderWidth = 0.5f;
    _profileButton.layer.borderColor = UIColorFromHex(@"A2A2A2", 1.0f).CGColor;
    _profileButton.layer.cornerRadius = _profileButton.frame.size.height/2;
    
    _shareButton.backgroundColor = [UIColor whiteColor];
    _shareButton.layer.cornerRadius = _profileButton.frame.size.height/2;
    
    [self animationViewConfig];
}

- (void)animationViewConfig {
    // 配置气泡的比例和放大锚点；配置妙推用户视图的缩放比例
    _bubbleView.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
    _bubbleView.layer.anchorPoint = CGPointMake(0.4f, 1.0f);
    _infectUserView.transform = CGAffineTransformMakeScale(0.84f, 0.84f);
    
    // 配置提示条，设置为隐藏
    _pushPromptLabel.alpha = 0.0f;
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
            [_profileButton sd_setImageWithURL:[NSURL URLWithString:newAvatarUrl]
                                      forState:UIControlStateNormal
                              placeholderImage:[UIImage imageNamed:@"HP-InfectUserDefaultHeader"]];
		}
	}
}

- (void)notificationWebSocketDidOpen:(NSNotification *)notification {
	[HXNoNetworkView hidden];
	[MiaAPIHelper sendUUIDWithCompleteBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
		if (success) {
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

- (void)notificationWebSocketDidReceiveMessage:(NSNotification *)notification {
	NSString *command = [notification userInfo][MiaAPIKey_ServerCommand];
	id ret = [notification userInfo][MiaAPIKey_Values][MiaAPIKey_Return];
	//NSLog(@"%@", command);

	if ([command isEqualToString:MiaAPICommand_User_PushUnreadComm]) {
		[self handlePushUnreadCommWithRet:[ret intValue] userInfo:[notification userInfo]];
	}
}

- (void)notificationWebSocketDidCloseWithCode:(NSNotification *)notification {
	NSLog(@"Connection Closed! (see logs)");
}

- (void)handlePushUnreadCommWithRet:(int)ret userInfo:(NSDictionary *) userInfo {
	BOOL isSuccess = (0 == ret);
	if (isSuccess) {
		[self updateProfileButtonWithUnreadCount:[userInfo[MiaAPIKey_Values][@"num"] intValue]];
	} else {
		NSLog(@"unread comment failed! error:%@", userInfo[MiaAPIKey_Values][MiaAPIKey_Error]);
	}
}

#pragma mark - Event Response
- (IBAction)profileButtonPressed {
    // 用户按钮点击事件，未登录显示登录页面，已登录显示用户信息页面
    if ([[UserSession standard] isLogined]) {
        ProfileViewController *vc = [[ProfileViewController alloc] initWitUID:[[UserSession standard] uid]
                                                                     nickName:[[UserSession standard] nick]
                                                                  isMyProfile:YES];
        [self.navigationController pushViewController:vc animated:YES];
	} else {
        LoginViewController *vc = [[LoginViewController alloc] init];
        vc.loginViewControllerDelegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)shareButtonPressed {
    // 音乐分享按钮点击事件，未登录显示登录页面，已登录显示音乐分享页面
    if ([[UserSession standard] isLogined]) {
        ShareViewController *vc = [[ShareViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        LoginViewController *vc = [[LoginViewController alloc] init];
        vc.loginViewControllerDelegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)tapGesture {
    if (_animating) {
        if (![[UserSession standard] isLogined]) {
            [self cancelLoginOperate];
        }
    } else {
        DetailViewController *vc = [[DetailViewController alloc] initWitShareItem:_playItem fromMyProfile:NO];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

static CGFloat OffsetHeightThreshold = 200.0f;  // 用户拖动手势触发动画阀值
- (IBAction)gestureEvent:(UIGestureRecognizer *)gesture {
    if ([gesture isKindOfClass:[UISwipeGestureRecognizer class]]) {
        // 滑动手势
        UISwipeGestureRecognizer *swipeGesture = (UISwipeGestureRecognizer *)gesture;
        switch (swipeGesture.direction) {
            case UISwipeGestureRecognizerDirectionUp: {
                [self startAnimation];
                break;
            }
            default:
                break;
        }
    } else if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
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
                if (!_playItem.isInfected) {
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
                        [_fishView stopAnimating];
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
}

- (void)showInfectUsers:(NSArray *)infectUsers {
    [_infectUserView removeAllItem];
    if (infectUsers) {
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
        [UIView animateWithDuration:0.3f animations:^{
            strongSelf.pushPromptLabel.alpha = 1.0f;
        } completion:nil];
    }];
}

- (void)updatePromptLabel {
    NSInteger count = _playItem.infectTotal;
    NSString *prompt = [NSString stringWithFormat:@"%@人%@妙推", @(count + 1), ((count > 5) ? @"等" : @"")];
    _pushPromptLabel.text = prompt;
}

- (void)reset {
    [_fishView stopAnimating];
    [_bubbleView reset];
    [_waveView reset];
    
    // 重新布局
    _fishBottomConstraint.constant = 20.0f;
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
                               completeBlock:
		 ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
			 if (success) {
				 [HXAlertBanner showWithMessage:@"评论成功" tap:nil];
			 } else {
				 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
				 [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"提交评论失败:%@", error] tap:nil];
			 }
		 } timeoutBlock:^(MiaRequestItem *requestItem) {
			 [HXAlertBanner showWithMessage:@"提交评论失败，网络请求超时" tap:nil];
		 }];
		[self startFinishedAnimation];
    } else {
        LoginViewController *vc = [[LoginViewController alloc] init];
        vc.loginViewControllerDelegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)updateProfileButtonWithUnreadCount:(int)unreadCommentCount {
    if (unreadCommentCount <= 0) {
        [_profileButton sd_setImageWithURL:[NSURL URLWithString:[[UserSession standard] avatar]]
                                  forState:UIControlStateNormal
                          placeholderImage:[UIImage imageNamed:@"HP-InfectUserDefaultHeader"]];
	} else {
        _profileButton.backgroundColor = UIColorFromHex(@"0BDEBC", 1.0f);
		[_profileButton setTitle:[NSString stringWithFormat:@"%d", unreadCommentCount] forState:UIControlStateNormal];
	}
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
             
             [_profileButton sd_setImageWithURL:[NSURL URLWithString:avatarUrlWithTime]
                                       forState:UIControlStateNormal
                               placeholderImage:[UIImage imageNamed:@"HP-InfectUserDefaultHeader"]];
             
             [UserDefaultsUtils saveValue:userInfo[MiaAPIKey_Values][@"uid"] forKey:UserDefaultsKey_UID];
             [UserDefaultsUtils saveValue:userInfo[MiaAPIKey_Values][@"nick"] forKey:UserDefaultsKey_Nick];
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
        __weak __typeof__(self)weakSelf = self;
        // 传播出去不需要切换歌曲，需要记录下传播的状态和上报服务器
        [MiaAPIHelper InfectMusicWithLatitude:[[LocationMgr standard] currentCoordinate].latitude
                                    longitude:[[LocationMgr standard] currentCoordinate].longitude
                                      address:[[LocationMgr standard] currentAddress]
                                         spID:_playItem.spID
                                completeBlock:
         ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
             if (success) {
                 __strong __typeof__(self)strongSelf = weakSelf;
                 strongSelf->_playItem.isInfected = YES;
                 [HXAlertBanner showWithMessage:@"妙推成功" tap:nil];
             } else {
                 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
                 [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"妙推失败:%@", error] tap:nil];
             }
         } timeoutBlock:^(MiaRequestItem *requestItem) {
             [HXAlertBanner showWithMessage:@"妙推失败，网络请求超时" tap:nil];
         }];
    }
}

- (void)showOfflineProfileWithPlayFavorite:(BOOL)playFavorite {
	if ([[UserSession standard] isCachedLogin]) {
		ProfileViewController *vc = [[ProfileViewController alloc] initWitUID:[[UserSession standard] uid]
																	 nickName:[[UserSession standard] nick]
																  isMyProfile:YES];
		vc.customDelegate = self;
		vc.playFavoriteOnceTime = playFavorite;
		[self.navigationController pushViewController:vc animated:playFavorite ? NO : YES];
	} else {
		LoginViewController *vc = [[LoginViewController alloc] init];
		vc.loginViewControllerDelegate = self;
		[self.navigationController pushViewController:vc animated:YES];
	}
}

- (void)showNoNetworkView {
	[HXNoNetworkView showOnViewController:self show:^{
		[self showOfflineProfileWithPlayFavorite:NO];
	} play:^{
		[self showOfflineProfileWithPlayFavorite:YES];
	}];
}

- (void)cancelLoginOperate {
    [self startWaveMoveUpAnimation];
    [self startHeaderViewPopBackAnimation];
    [self startFinshAndBubbleHiddenAnimation];
}

- (void)displayWithInfectState:(BOOL)infected {
    _pushPromptLabel.alpha = 0.0f;
    _bubbleView.hidden = infected;
    _fishView.hidden = infected;
    
    if (infected) {
        [self startInfectedStateAnimation];
    } else {
        [self startUnInfectedStateAnimation];
    }
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
    _fishBottomConstraint.constant = self.view.frame.size.height/2 - 140.0f;
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf.fishView.transform = CGAffineTransformIdentity;
        [strongSelf.view layoutIfNeeded];
    } completion:nil];
    
    [self startBubbleScaleAnimation];
    [self startWaveMoveDownAnimation];
    [self startHeaderViewPopAnimation];
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
    [_waveView waveMoveDownAnimation:^{
    }];
}

// 波浪升起动画
- (void)startWaveMoveUpAnimation {
    __weak __typeof__(self)weakSelf = self;
    [_waveView waveMoveUpAnimation:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf reset];
    }];
}

- (void)startFinshAndBubbleHiddenAnimation {
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.4f animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf.fishView.alpha = 0.0f;
        strongSelf.bubbleView.alpha = 0.0f;
    } completion:nil];
}

// 头像弹出动画
- (void)startHeaderViewPopAnimation {
    _headerViewBottomConstraint.constant = 40.0f;
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:1.0f delay:0.4f usingSpringWithDamping:0.5f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveEaseIn animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf.infectUserView.transform = CGAffineTransformIdentity;
        [strongSelf.infectUserView layoutIfNeeded];
    } completion:nil];
    if ([[UserSession standard] isLogined]) {
        [self addPushUserHeader];
    }
}

// 头像收回动画
- (void)startHeaderViewPopBackAnimation {
    _headerViewBottomConstraint.constant = 2.0f;
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:1.0f delay:0.0f usingSpringWithDamping:0.5f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveEaseIn animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf.infectUserView.transform = CGAffineTransformMakeScale(0.84f, 0.84f);
        [strongSelf.infectUserView layoutIfNeeded];
    } completion:nil];
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
    [self startHeaderViewPopAnimation];
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
    [self userStartNeedLogin];
    [self stopAnimation];
}

#pragma mark - Login View Controller Delegate Methods
- (void)loginViewControllerDidSuccess {
    if ([[UserSession standard] isLogined]) {
        int unreadCommentCount = [[[UserSession standard] unreadCommCnt] intValue];
        [self updateProfileButtonWithUnreadCount:unreadCommentCount];
    }
}

#pragma mark - ProfileViewControllerDelegate Methods
- (void)profileViewControllerWillDismiss {
	if (![[WebSocketMgr standard] isOpen]) {
		[self showNoNetworkView];
	}
}

#pragma mark - HXRadioViewControllerDelegate Methods
- (void)userWouldLikeSeeSharerHomePageWithItem:(ShareItem *)item {
	ProfileViewController *vc = [[ProfileViewController alloc] initWitUID:item.uID
																 nickName:item.sNick
															  isMyProfile:NO];
	[self.navigationController pushViewController:vc animated:YES];
}

- (void)userStartNeedLogin {
	LoginViewController *vc = [[LoginViewController alloc] init];
	vc.loginViewControllerDelegate = self;
	[self.navigationController pushViewController:vc animated:YES];
}

- (void)shouldDisplayInfectUsers:(ShareItem *)item {
    _playItem = item;
    [self showInfectUsers:item.infectUsers];
    [self displayWithInfectState:item.isInfected];
}

- (void)musicDidChange:(ShareItem *)item {
//    _playItem = item;
//    [self displayWithInfectState:item.isInfected];
}

@end
