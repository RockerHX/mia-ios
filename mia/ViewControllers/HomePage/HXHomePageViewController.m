//
//  HXHomePageViewController.m
//  mia
//
//  Created by miaios on 15/10/9.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXHomePageViewController.h"
#import "HXRadioViewController.h"
#import "HXWaveView.h"
#import "HXBubbleView.h"
#import "UserSession.h"
#import "LoginViewController.h"
#import "ProfileViewController.h"
#import "ShareViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "CLLocation+YCLocation.h"
#import "WebSocketMgr.h"
#import "NSString+IsNull.h"
#import "UIButton+WebCache.h"
#import "MiaAPIHelper.h"
#import "UserDefaultsUtils.h"
#import "HXNoNetworkView.h"
#import "MBProgressHUDHelp.h"
#import "InfectUserItem.h"
#import "UIImageView+WebCache.h"

static NSString * kAlertMsgNoNetwork			= @"没有网络连接，请稍候重试";

@interface HXHomePageViewController () <LoginViewControllerDelegate, HXBubbleViewDelegate, CLLocationManagerDelegate, HXRadioViewControllerDelegate> {
    BOOL    _animating;             // 动画执行标识
    CGFloat _fishViewCenterY;       // 小鱼中心高度位置
    NSTimer *_timer;                // 定时器，用户在秒推动作时默认不评论定时执行结束动画
    ShareItem *_playItem;

	CLLocationManager 		*_locationManager;
	CLLocationCoordinate2D 	_currentCoordinate;
	NSString				*_currentAddress;
}

@end

@implementation HXHomePageViewController

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initConfig];
    [self viewConfig];
    
    [[WebSocketMgr standard] watchNetworkStatus];
    [self initLocationMgr];
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
    
    _profileButton.layer.borderWidth = 0.5f;
    _profileButton.layer.borderColor = UIColorFromHex(@"A2A2A2", 1.0f).CGColor;
    _profileButton.layer.cornerRadius = _profileButton.frame.size.height/2;
    
    // 配置气泡的比例和放大锚点；配置秒推用户视图的缩放比例
    _bubbleView.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
    _bubbleView.layer.anchorPoint = CGPointMake(0.4f, 1.0f);
    _headerView.transform = CGAffineTransformMakeScale(0.7f, 0.7f);
    
    // 配置波浪颜色，波浪高度以及波动运动速度；配置提示条，设置为隐藏
    _waveView.tintColor = [UIColor colorWithRed:68.0f/255.0f green:209.0f/255.0f blue:192.0f/255.0f alpha:1.0f];
    _waveView.percent = 0.6f;
    _waveView.speed = 3.0f;
    _pushPromptLabel.alpha = 0.0f;
}

- (void)initLocationMgr {
	if (nil == _locationManager) {
		_locationManager = [[CLLocationManager alloc] init];
	}
	_locationManager.delegate = self;
	//设置定位的精度
	_locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
	//设置定位服务更新频率
	_locationManager.distanceFilter = 500;

	if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0) {
		[_locationManager requestWhenInUseAuthorization];	// 前台定位
		//[mylocationManager requestAlwaysAuthorization];	// 前后台同时定位
	}
	[_locationManager startUpdatingLocation];
}

#pragma mark - Notification
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	//	NSLog(@"keyPath = %@, change = %@, context = %s", keyPath, change, (char *)context);
	if ([keyPath isEqualToString:UserSessionKey_Avatar]) {
		NSString *newAvatarUrl = change[NSKeyValueChangeNewKey];
		if ([NSString isNull:newAvatarUrl]) {
			[_profileButton setImage:[UIImage imageNamed:@"default_avatar"] forState:UIControlStateNormal];
        } else {
            [_profileButton sd_setImageWithURL:[NSURL URLWithString:newAvatarUrl]
                                      forState:UIControlStateNormal
                              placeholderImage:[UIImage imageNamed:@"default_avatar"]];
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
	static NSString * kAlertMsgWebSocketFailed = @"服务器连接错误（WebSocket失败），断线重连中...";
	[[MBProgressHUDHelp standarMBProgressHUDHelp] showHUDWithModeText:kAlertMsgWebSocketFailed];
}

- (void)notificationWebSocketDidAutoReconnectFailed:(NSNotification *)notification {
	[HXNoNetworkView showOnViewController:self show:^{
		NSLog(@"show...");
	} play:^{
		NSLog(@"play...");
	}];
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
                break;
            }
            // 手势结束，失败，取消，停止小鱼游动，小鱼弹回，用于用户取消操作
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateFailed:
            case UIGestureRecognizerStateCancelled: {
                if (!_animating) {
                    [_fishView stopAnimating];
                    __weak __typeof__(self)weakSelf = self;
                    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                        __strong __typeof__(self)strongSelf = weakSelf;
                        strongSelf.fishView.center = CGPointMake(strongSelf.fishView.center.x, _fishViewCenterY);
                    } completion:nil];
                }
                break;
            }
                
            default:
                break;
        }
    }
}

#pragma mark - Private Methods
- (void)startAnimation {
    if (!_animating) {
        [self infectShare];
        [self startWaveAnimation];
        [self startPopFishAnimation];
    }
    _animating = YES;
}

- (void)stopAnimation {
    if (_animating) {
        [self reset];
    }
    _animating = NO;
}

- (void)showInfectUsers:(NSArray *)infectUsers {
    _headerViewWidthConstraint.constant = infectUsers.count*50.0f + 40.0f;
    for (InfectUserItem *item in infectUsers) {
        UIImageView *infectUserHeader = [[UIImageView alloc] init];
        infectUserHeader.contentMode = UIViewContentModeCenter;
        infectUserHeader.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
        [infectUserHeader sd_setImageWithURL:[NSURL URLWithString:item.avatar]];
        [_headerView addArrangedSubview:infectUserHeader];
    }
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf.headerView layoutIfNeeded];
    } completion:^(BOOL finished) {
        // 秒推用户头像跳动动画
        [UIView animateWithDuration:0.4f delay:0.0f usingSpringWithDamping:0.7f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            __strong __typeof__(self)strongSelf = weakSelf;
            for (UIView *header in strongSelf.headerView.arrangedSubviews) {
                header.transform = CGAffineTransformIdentity;
            }
        } completion:nil];
    }];
}

- (void)addPushUserHeader {
    // 秒推用户头像添加以及动画
    _headerViewWidthConstraint.constant = _headerView.arrangedSubviews.count*50.0f + 40.0f;
    UIImageView *pushUserHeader = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Header1"]];
    pushUserHeader.contentMode = UIViewContentModeCenter;
    pushUserHeader.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
    [_headerView insertArrangedSubview:pushUserHeader atIndex:0];
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf.headerView layoutIfNeeded];
    } completion:^(BOOL finished) {
        // 秒推用户头像跳动动画
        [UIView animateWithDuration:0.4f delay:0.0f usingSpringWithDamping:0.7f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            pushUserHeader.transform = CGAffineTransformIdentity;
        } completion:nil];
        
        // 秒推提示条显示动画
        [UIView animateWithDuration:0.3f animations:^{
            __strong __typeof__(self)strongSelf = weakSelf;
            strongSelf.pushPromptLabel.alpha = 1.0f;
        } completion:nil];
    }];
}

- (void)reset {
    // 移除加入的秒推用户头像
    UIView *header = _headerView.arrangedSubviews.firstObject;
    if (header) {
        [_headerView removeArrangedSubview:header];
        [header removeFromSuperview];
    }
    
    // 重新布局
    _waveViewBottomConstraint.constant = 0.0f;
    _fishBottomConstraint.constant = 40.0f;
    _headerViewBottomConstraint.constant = 0.0f;
    _headerViewWidthConstraint.constant = 200.0f;
    [self viewConfig];
    [self.view layoutIfNeeded];
    
    [_fishView stopAnimating];
    [_bubbleView reset];
    
    _fishView.alpha = 1.0f;
    _bubbleView.alpha = 1.0f;
    _fishView.transform = CGAffineTransformIdentity;
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
                               completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
                                   if (success) {
                                       // TODO
                                       NSLog(@"Comment Success");
                                   }
                               } timeoutBlock:^(MiaRequestItem *requestItem) {
                                   NSLog(@"Comment Timeout");
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
        NSString *avatarUrl = [[UserSession standard] avatar];
        NSString *avatarUrlWithTime = [NSString stringWithFormat:@"%@?t=%ld", avatarUrl, (long)[[NSDate date] timeIntervalSince1970]];
        [_profileButton sd_setImageWithURL:[NSURL URLWithString:avatarUrlWithTime]
                                  forState:UIControlStateNormal
                          placeholderImage:[UIImage imageNamed:@"default_avatar"]];
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
					  completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
						  if (success) {
							  [[UserSession standard] setUid:userInfo[MiaAPIKey_Values][@"uid"]];
							  [[UserSession standard] setNick:userInfo[MiaAPIKey_Values][@"nick"]];
							  [[UserSession standard] setUtype:userInfo[MiaAPIKey_Values][@"utype"]];
							  [[UserSession standard] setUnreadCommCnt:userInfo[MiaAPIKey_Values][@"unreadCommCnt"]];

							  [MiaAPIHelper getUserInfoWithUID:userInfo[MiaAPIKey_Values][@"uid"]
												 completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
													 if (success) {
														 NSString *avatarUrl = userInfo[MiaAPIKey_Values][@"info"][0][@"uimg"];
                                                         NSString *avatarUrlWithTime = [NSString stringWithFormat:@"%@?t=%ld", avatarUrl, (long)[[NSDate date] timeIntervalSince1970]];
                                                         [_profileButton sd_setImageWithURL:[NSURL URLWithString:avatarUrlWithTime]
                                                                                   forState:UIControlStateNormal
                                                                           placeholderImage:[UIImage imageNamed:@"default_avatar"]];
													 } else {
														 NSLog(@"getUserInfoWithUID failed");
													 }
												 } timeoutBlock:^(MiaRequestItem *requestItem) {
													 NSLog(@"getUserInfoWithUID timeout");
												 }];
						  } else {
							  NSLog(@"audo login failed!error:%@", userInfo[MiaAPIKey_Values][MiaAPIKey_Error]);
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
    // 传播出去不需要切换歌曲，需要记录下传播的状态和上报服务器
    [MiaAPIHelper InfectMusicWithLatitude:0//[_radioViewDelegate radioViewCurrentCoordinate].latitude
                                longitude:0//[_radioViewDelegate radioViewCurrentCoordinate].longitude
                                  address:@""//[_radioViewDelegate radioViewCurrentAddress]
                                     spID:_playItem.spID
                            completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
                                NSLog(@"InfectMusic %d", success);
                            } timeoutBlock:^(MiaRequestItem *requestItem) {
                                NSLog(@"InfectMusic timeout");
                            }];
}

#pragma mark - Animation
- (void)startWaveAnimation {
    [_waveView startAnimating];
}

- (void)stopWaveAnimation {
    [_waveView stopAnimating];
}

// 小鱼跳出动画
- (void)startPopFishAnimation {
    _fishBottomConstraint.constant = self.view.frame.size.height/2 - 120.0f;
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf.fishView.transform = CGAffineTransformIdentity;
        [strongSelf.view layoutIfNeeded];
    } completion:nil];
    
    [self startBubbleScaleAnimation];
    [self startWaveMoveDownAnimation];
    [self startHeaderViewScaleAnimation];
}

// 气泡弹出动画
- (void)startBubbleScaleAnimation {
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.5f delay:0.1f usingSpringWithDamping:0.7f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf.bubbleView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf executeTimer];
    }];
}

// 波浪退出动画
- (void)startWaveMoveDownAnimation {
    _waveViewBottomConstraint.constant = -_waveViewHeightConstraint.constant/2;
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf stopWaveAnimation];
    }];
}

// 头像弹出动画
- (void)startHeaderViewScaleAnimation {
    _headerViewBottomConstraint.constant = 40.0f;
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:1.0f delay:0.4f usingSpringWithDamping:0.5f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveEaseIn animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf.headerView.transform = CGAffineTransformIdentity;
        [strongSelf.headerView layoutIfNeeded];
    } completion:nil];
    [self addPushUserHeader];
}

// 秒推完成，结束动画
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
        UIView *header = strongSelf.headerView.arrangedSubviews.firstObject;
        CGPoint endPont = CGPointMake(strongSelf.headerView.frame.origin.x +  header.center.x, strongSelf.headerView.frame.origin.y);
        strongSelf.fishView.center = endPont;
        strongSelf.bubbleView.center = endPont;
    } completion:^(BOOL finished) {
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf stopAnimation];
    }];
}

#pragma mark - HXBubbleViewDelegate Methods
- (void)bubbleViewStartEdit:(HXBubbleView *)bubbleView {
    // 产品设计内容，用于一旦编辑气泡内容，必须关闭小鱼洄游动画定时器
    [_timer invalidate];
}

- (void)bubbleView:(HXBubbleView *)bubbleView shouldSendComment:(NSString *)comment {
    // 用户触发秒推评论发送之后关闭键盘并执行秒推评论数据请求
    [self.view endEditing:YES];
    [self startPushMusicRequsetWithComment:comment];
}

#pragma mark - Login View Controller Delegate Methods
- (void)loginViewControllerDidSuccess {
    if ([[UserSession standard] isLogined]) {
        int unreadCommentCount = [[[UserSession standard] unreadCommCnt] intValue];
        [self updateProfileButtonWithUnreadCount:unreadCommentCount];
    }
}

#pragma mark - HXRadioViewControllerDelegate Methods
- (void)userWouldLikeSeeSharerHomePageWithItem:(ShareItem *)item {
	ProfileViewController *vc = [[ProfileViewController alloc] initWitUID:item.uID
																 nickName:item.sNick
															  isMyProfile:NO];
	[self.navigationController pushViewController:vc animated:YES];
}

- (void)userStarNeedLogin {
	LoginViewController *vc = [[LoginViewController alloc] init];
	vc.loginViewControllerDelegate = self;
	[self.navigationController pushViewController:vc animated:YES];
}

- (void)shouldDisplayInfectUsers:(ShareItem *)item {
    _playItem = item;
    [self showInfectUsers:item.infectUsers];
}

@end
