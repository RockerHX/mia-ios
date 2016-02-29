//
//  HXProfileViewController.m
//  mia
//
//  Created by miaios on 16/1/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXProfileViewController.h"
#import "HXProfileCoverContainerViewController.h"
#import "HXProfileDetailContainerViewController.h"
#import "HXNavigationBar.h"
#import "MiaAPIHelper.h"
#import "UIImageView+WebCache.h"
//#import "FriendViewController.h"
#import "UserSession.h"
//#import "HXSettingViewController.h"
#import "WebSocketMgr.h"
#import "HXAlertBanner.h"
//#import "HXMessageCenterViewController.h"

@interface HXProfileViewController () <
HXProfileDetailContainerViewControllerDelegate,
HXNavigationBarDelegate
>
@end

@implementation HXProfileViewController {
    BOOL _pushToFrends;
    
    UIStatusBarStyle  _statusBarStyle;
    HXProfileCoverContainerViewController *_coverContainerViewController;
    HXProfileDetailContainerViewController *_detailContainerViewController;

	NSUInteger _fansCount;
	NSUInteger _followCount;
    NSUInteger _followState;
}

#pragma mark - View Controller Life Cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    animated = (self.navigationController.viewControllers.count > 2);
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
	[self fetchProfileData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    BOOL hidden = _pushToFrends ?: (self.navigationController.viewControllers.count < 2);
    [self.navigationController setNavigationBarHidden:hidden animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

+ (NSString *)navigationControllerIdentifier {
    return @"HXProfileNavigationController";
}

+ (HXStoryBoardName)storyBoardName {
    return HXStoryBoardNameProfile;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return _statusBarStyle;
}

- (void)dealloc {
    [[UserSession standard] removeObserver:self forKeyPath:UserSessionKey_NotifyCount context:nil];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *identifier = segue.identifier;
    if ([identifier isEqualToString:[HXProfileCoverContainerViewController segueIdentifier]]) {
        _coverContainerViewController = segue.destinationViewController;
    } else if ([identifier isEqualToString:[HXProfileDetailContainerViewController segueIdentifier]]) {
        _detailContainerViewController = segue.destinationViewController;
        _detailContainerViewController.uid = _uid;
        _detailContainerViewController.delegate = self;
    }
}

#pragma mark - KVO Methods
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:UserSessionKey_NotifyCount]) {
		[self showMessagePromptView];
    }
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    [[UserSession standard] addObserver:self forKeyPath:UserSessionKey_NotifyCount options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewConfigure {
	_navigationBar.delegate = self;
	[self showMessagePromptView];
}

#pragma mark - Event Response
- (IBAction)settingButtonPressed {
//    _pushToFrends = NO;
//    HXSettingViewController *settingViewController = [HXSettingViewController instance];
//    [self.navigationController pushViewController:settingViewController animated:YES];
}

#pragma mark - Private Methods
- (void)fetchProfileData {
    [MiaAPIHelper getUserInfoWithUID:_uid completeBlock:
     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
         if (success) {
             NSDictionary *data = userInfo[MiaAPIKey_Values][@"info"][0];
             HXProfileHeaderModel *model = [HXProfileHeaderModel mj_objectWithKeyValues:data];
             [_detailContainerViewController.header displayWithHeaderModel:model];
             [_coverContainerViewController.avatarBG sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:@"HP-InfectUserDefaultHeader"]];
             
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
    
//	[_detailContainerViewController.header.followButton setHidden:[_uid isEqualToString:[UserSession standard].uid]];
//    [_detailContainerViewController.header.followButton setTitle:prompt forState:UIControlStateNormal];
}

- (void)displayFansCountWithFollowState:(NSUInteger)state {
    NSUInteger count = state ? 1 : -1;
    _fansCount = _detailContainerViewController.header.fansCountLabel.text.integerValue + count;
    _fansCount = _fansCount ?: 0;
    [_detailContainerViewController.header.fansCountLabel setText:@(_fansCount).stringValue];
}

- (void)showMessagePromptView {
//	[_detailContainerViewController.header.messageAvatar sd_setImageWithURL:[NSURL URLWithString:[UserSession standard].notifyUserpic]
//														   placeholderImage:[UIImage imageNamed:@"HP-InfectUserDefaultHeader"]];
//	_detailContainerViewController.header.messageCountLabel.text = @([UserSession standard].notifyCnt).stringValue;
//
//
//	[_detailContainerViewController.header.messagePromptView setHidden:([UserSession standard].notifyCnt <= 0) || !_type];
}

#pragma mark - HXProfileDetailContainerViewControllerDelegate Methods
- (void)detailContainerDidScroll:(HXProfileDetailContainerViewController *)controller scrollOffset:(CGPoint)scrollOffset {
//    CGFloat scrollThreshold = _detailContainerViewController.header.height - 64.0f;
//    CGFloat alpha = scrollOffset.y/scrollThreshold;
//    _navigationBar.colorAlpha = alpha;
//    _statusBarStyle = ((alpha > 0.1f) ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent);
//    [self setNeedsStatusBarAppearanceUpdate];
//    
//    [_coverContainerViewController scrollPosition:((scrollOffset.y < scrollThreshold) ? UICollectionViewScrollPositionTop : UICollectionViewScrollPositionBottom)];
}

- (void)detailContainer:(HXProfileDetailContainerViewController *)controller takeAction:(HXProfileDetailContainerAction)action {
    switch (action) {
        case HXProfileDetailContainerActionShowMusicDetail: {
            _pushToFrends = NO;
            break;
        }
        case HXProfileDetailContainerActionShowFans: {
            _pushToFrends = YES;
//            FriendViewController *friendVC = [[FriendViewController alloc] initWithType:UserListViewTypeFans
//                                                                                 isHost:_type
//                                                                                    uID:_uid
//                                                                              fansCount:_fansCount
//                                                                         followingCount:_followCount];
//            [self.navigationController pushViewController:friendVC animated:YES];
            break;
        }
        case HXProfileDetailContainerActionShowFollow: {
            _pushToFrends = YES;
//            FriendViewController *friendVC = [[FriendViewController alloc] initWithType:UserListViewTypeFollowing
//                                                                                 isHost:_type
//                                                                                    uID:_uid
//                                                                              fansCount:_fansCount
//                                                                         followingCount:_followCount];
//            [self.navigationController pushViewController:friendVC animated:YES];
            break;
        }
        case HXProfileDetailContainerActionShoulFollow: {
            if ([UserSession standard].state) {
                [MiaAPIHelper followWithUID:_uid isFollow:!_followState completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
                    _followState = !_followState;
                    [HXAlertBanner showWithMessage:(_followState ? @"添加关注成功" : @"取消关注成功") tap:nil];
                    [self displayFollowState:_followState];
                    [self displayFansCountWithFollowState:_followState];
                } timeoutBlock:^(MiaRequestItem *requestItem) {
                    [HXAlertBanner showWithMessage:@"请求超时，请重试！" tap:nil];
                }];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedLoginNotification object:nil];
            }
            break;
        }
        case HXProfileDetailContainerActionShowMessageCenter: {
//            _pushToFrends = NO;
//			HXMessageCenterViewController *messageCenterViewController = [HXMessageCenterViewController instance];
//			[self.navigationController pushViewController:messageCenterViewController animated:YES];
			break;
		}
    }
}

#pragma mark - HXNavigationBarDelegate Methods
- (void)navigationBarDidBackAction {
	[_detailContainerViewController stopMusic];
}

@end
