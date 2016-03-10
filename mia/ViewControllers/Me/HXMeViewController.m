//
//  HXMeViewController.m
//  mia
//
//  Created by miaios on 16/2/17.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXMeViewController.h"
#import "HXMeCoverContainerViewController.h"
#import "HXMeDetailContainerViewController.h"
#import "HXMeNavigationBar.h"
#import "MiaAPIHelper.h"
#import "HXUserSession.h"
#import "HXAlertBanner.h"
#import "WebSocketMgr.h"
#import "MusicMgr.h"
#import "FriendViewController.h"
#import "HXPlayViewController.h"
#import "HXSettingViewController.h"
#import "HXMessageCenterViewController.h"


@interface HXMeViewController () <
HXMeDetailContainerViewControllerDelegate,
HXMeNavigationBarDelegate,
FriendViewControllerDelegate
>
@end


@implementation HXMeViewController {
    BOOL _hiddenNavigationBar;
    
    UIStatusBarStyle  _statusBarStyle;
    HXMeCoverContainerViewController *_coverContainerViewController;
    HXMeDetailContainerViewController *_detailContainerViewController;
    
    NSUInteger _fansCount;
    NSUInteger _followCount;
    NSUInteger _followState;
}

#pragma mark - Class Methods
+ (NSString *)navigationControllerIdentifier {
    return @"HXMeNavgationController";
}

+ (HXStoryBoardName)storyBoardName {
    return HXStoryBoardNameMe;
}

#pragma mark - StatusBar
- (UIStatusBarStyle)preferredStatusBarStyle {
    return _statusBarStyle;
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *identifier = segue.identifier;
    if ([identifier isEqualToString:[HXMeCoverContainerViewController segueIdentifier]]) {
        _coverContainerViewController = segue.destinationViewController;
    } else if ([identifier isEqualToString:[HXMeDetailContainerViewController segueIdentifier]]) {
        _detailContainerViewController = segue.destinationViewController;
        _detailContainerViewController.uid = [HXUserSession share].uid;
        _detailContainerViewController.delegate = self;
    }
}

#pragma mark - View Controller Life Cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    animated = (self.navigationController.viewControllers.count > 2);
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [self updateUI];
    [self fetchProfileData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    BOOL hidden = _hiddenNavigationBar ?: (self.navigationController.viewControllers.count < 2);
    [self.navigationController setNavigationBarHidden:hidden animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MusicMgrNotificationPlayerEvent object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationPushUnread object:nil];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    _statusBarStyle = UIStatusBarStyleLightContent;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationPlayerEvent:) name:MusicMgrNotificationPlayerEvent object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketPushUnread:) name:WebSocketMgrNotificationPushUnread object:nil];
}

- (void)viewConfigure {
    _navigationBar.delegate = self;
    [self showMessagePromptView];
}

#pragma mark - Notification Methods
- (void)notificationPlayerEvent:(NSNotification *)notification {
    MiaPlayerEvent event = [notification.userInfo[MusicMgrNotificationKey_PlayerEvent] unsignedIntegerValue];
    
    switch (event) {
        case MiaPlayerEventDidPlay: {
            _navigationBar.stateView.state = HXMusicStatePlay;
            break;
        }
        case MiaPlayerEventDidPause:
        case MiaPlayerEventDidCompletion: {
            _navigationBar.stateView.state = HXMusicStateStop;
            break;
        }
    }
}

- (void)notificationWebSocketPushUnread:(NSNotification *)notification {
	id ret = [notification userInfo][MiaAPIKey_Values][MiaAPIKey_Return];
	if (0 == [ret intValue]) {
		[self updateMessagePrompt];
	}
}

#pragma mark - Private Methods
- (void)updateUI {
    [self updateMusicEntryState];
	[self updateMessagePrompt];
}

- (void)updateMusicEntryState {
    _navigationBar.stateView.state = ([MusicMgr standard].isPlaying ? HXMusicStatePlay : HXMusicStateStop);
//    _navigationBar.stateView.stateIcon.tintColor = _navigationBar.color;
}

- (void)updateMessagePrompt {
	HXUserSession *session = [HXUserSession share];
	_detailContainerViewController.header.messagePromptView.hidden = !session.notify;
	[_detailContainerViewController.header.messagePromptView displayWithAvatarURL:session.user.notifyAvatar promptCount:session.user.notifyCount];
}

- (void)fetchProfileData {
    [MiaAPIHelper getUserInfoWithUID:[HXUserSession share].uid completeBlock:
     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
         if (success) {
             NSDictionary *data = userInfo[MiaAPIKey_Values][@"info"][0];
             HXProfileHeaderModel *model = [HXProfileHeaderModel mj_objectWithKeyValues:data];
             [_detailContainerViewController.header displayWithHeaderModel:model];
             [_navigationBar setTitle:model.nickName];
             _coverContainerViewController.imageURL = model.avatar;
             
             _fansCount = [model.fansCount integerValue];
             _followCount = [model.followCount integerValue];
             NSUInteger follow = [userInfo[MiaAPIKey_Values][@"info"][0][@"follow"] integerValue];            // 0表示没关注，1表示关注，2表示相互关注
             [self displayFollowState:follow];
         } else {
             NSLog(@"getUserInfoWithUID failed");
         }
     } timeoutBlock:^(MiaRequestItem *requestItem) {
         NSLog(@"getUserInfoWithUID timeout");
     }];
}

- (void)displayFollowState:(NSUInteger)state {
    _followState = state;
    NSString *prompt = @"关注";
    switch (state) {
        case 1: {
            prompt = @"已关注";
            break;
        }
        case 2: {
            prompt = @"相互关注";
            break;
        }
    }
}

- (void)displayFansCountWithFollowState:(NSUInteger)state {
    NSUInteger count = state ? 1 : -1;
    _fansCount = _detailContainerViewController.header.fansCountLabel.text.integerValue + count;
    _fansCount = _fansCount ?: 0;
    [_detailContainerViewController.header.fansCountLabel setText:@(_fansCount).stringValue];
}

- (void)showMessagePromptView {
//	[_detailContainerViewController.header.messageAvatar sd_setImageWithURL:[NSURL URLWithString:[UserSession standard].notifyUserpic]
//														   placeholderImage:[UIImage imageNamed:@"C-AvatarDefaultIcon"]];
//	_detailContainerViewController.header.messageCountLabel.text = @([UserSession standard].notifyCnt).stringValue;
//
//
//	[_detailContainerViewController.header.messagePromptView setHidden:([UserSession standard].notifyCnt <= 0) || !_type];
}

#pragma mark - HXMeDetailContainerViewControllerDelegate Methods
- (void)detailContainerDidScroll:(HXMeDetailContainerViewController *)controller scrollOffset:(CGPoint)scrollOffset {
    CGFloat scrollThreshold = _detailContainerViewController.header.height - 64.0f;
    CGFloat alpha = scrollOffset.y/scrollThreshold;
    _navigationBar.colorAlpha = alpha;
    _statusBarStyle = ((alpha > 0.1f) ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent);
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)detailContainer:(HXMeDetailContainerViewController *)controller takeAction:(HXProfileDetailContainerAction)action {
    switch (action) {
        case HXProfileDetailContainerActionShowSetting: {
            _hiddenNavigationBar = NO;
            [self.navigationController pushViewController:[HXSettingViewController instance] animated:YES];
            break;
        }
        case HXProfileDetailContainerActionShowFans: {
            _hiddenNavigationBar = YES;
            FriendViewController *friendVC = [[FriendViewController alloc] initWithType:UserListViewTypeFans
                                                                                 isHost:YES
                                                                                    uID:[HXUserSession share].uid
                                                                              fansCount:_fansCount
                                                                         followingCount:_followCount];
			friendVC.delegate = self;
            [self.navigationController pushViewController:friendVC animated:YES];
            break;
        }
        case HXProfileDetailContainerActionShowFollow: {
            _hiddenNavigationBar = YES;
            FriendViewController *friendVC = [[FriendViewController alloc] initWithType:UserListViewTypeFollowing
                                                                                 isHost:YES
                                                                                    uID:[HXUserSession share].uid
                                                                              fansCount:_fansCount
                                                                         followingCount:_followCount];
			friendVC.delegate = self;
            [self.navigationController pushViewController:friendVC animated:YES];
            break;
        }
        case HXProfileDetailContainerActionShowMessageCenter: {
            _hiddenNavigationBar = NO;
			HXMessageCenterViewController *messageCenterViewController = [HXMessageCenterViewController instance];
			[self.navigationController pushViewController:messageCenterViewController animated:YES];
            break;
        }
    }
}

#pragma mark - HXMeNavigationBarDelegate Methods
- (void)navigationBar:(HXMeNavigationBar *)bar takeAction:(HXMeNavigationAction)action {
    switch (action) {
        case HXMeNavigationActionMusic: {
            if ([MusicMgr standard].currentItem) {
                _hiddenNavigationBar = YES;
                UINavigationController *playNavigationController = [HXPlayViewController navigationControllerInstance];
                __weak __typeof__(self)weakSelf = self;
                [self presentViewController:playNavigationController animated:YES completion:^{
                    __strong __typeof__(self)strongSelf = weakSelf;
                    strongSelf->_hiddenNavigationBar = NO;
                }];
            }
            break;
        }
    }
}


#pragma mark - FriendViewControllerDelegate
- (void)friendViewControllerActionDismiss {
	_hiddenNavigationBar = NO;
}

@end
