//
//  HXProfileViewController.m
//  mia
//
//  Created by miaios on 16/1/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXProfileViewController.h"
#import "HXNavigationBar.h"
#import "HXProfileCoverContainerViewController.h"
#import "MiaAPIHelper.h"
#import "UIImageView+WebCache.h"
#import "FriendViewController.h"
#import "UserSession.h"
#import "HXSettingViewController.h"
#import "WebSocketMgr.h"
#import "HXAlertBanner.h"
#import "HXMessageCenterViewController.h"

@interface HXProfileViewController () <
HXProfileDetailContainerViewControllerDelegate,
HXNavigationBarDelegate
>
@end

@implementation HXProfileViewController {
    BOOL  _pushed;
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
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
	_pushed = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (!_pushed && _type) {
        return;
    }
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
        _detailContainerViewController.type = _type;
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
    
    [self showHUD];
    [self fetchProfileData];
}

- (void)viewConfigure {
	_navigationBar.delegate = self;
    _settingButton.hidden = !_type;
	[self showMessagePromptView];
}

#pragma mark - Event Response
- (IBAction)settingButtonPressed {
    _pushed = YES;
    HXSettingViewController *settingViewController = [HXSettingViewController instance];
    [self.navigationController pushViewController:settingViewController animated:YES];
}

#pragma mark - Private Methods
- (void)fetchProfileData {
    [MiaAPIHelper getUserInfoWithUID:_uid completeBlock:
     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
         if (success) {
             NSString *avatarUrl = userInfo[MiaAPIKey_Values][@"info"][0][@"uimg"];
             NSString *nickName = userInfo[MiaAPIKey_Values][@"info"][0][@"nick"];
             _fansCount = [userInfo[MiaAPIKey_Values][@"info"][0][@"fansCnt"] integerValue];
             _followCount = [userInfo[MiaAPIKey_Values][@"info"][0][@"followCnt"] integerValue];
             _detailContainerViewController.shareCount = [userInfo[MiaAPIKey_Values][@"info"][0][@"shareCnt"] integerValue];
             _detailContainerViewController.favoriteCount = [userInfo[MiaAPIKey_Values][@"info"][0][@"favCnt"] integerValue];
             NSUInteger follow = [userInfo[MiaAPIKey_Values][@"info"][0][@"follow"] integerValue];            // 0表示没关注，1表示关注，2表示相互关注
             NSArray *imgs = userInfo[MiaAPIKey_Values][@"info"][0][@"background"];
             NSLog(@"user info: %ld, %ld, %ld, %@", _fansCount, _followCount, follow, imgs);
             // end for test
             
             _coverContainerViewController.dataSource = imgs;
             
             NSString *avatarUrlWithTime = [NSString stringWithFormat:@"%@?t=%ld", avatarUrl, (long)[[NSDate date] timeIntervalSince1970]];
             [_detailContainerViewController.header.avatar sd_setImageWithURL:[NSURL URLWithString:avatarUrlWithTime]
                                                             placeholderImage:[UIImage imageNamed:@"HP-InfectUserDefaultHeader"]];
             _detailContainerViewController.header.nickNameLabel.text = nickName;
             _detailContainerViewController.header.fansCountLabel.text = @(_fansCount).stringValue;
             _detailContainerViewController.header.followCountLabel.text = @(_followCount).stringValue;
             
             [self displayFollowState:follow];
             
             [self hiddenHUD];
         } else {
             [self hiddenHUD];
             NSLog(@"getUserInfoWithUID failed");
         }
     } timeoutBlock:^(MiaRequestItem *requestItem) {
         [self hiddenHUD];
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
	[_detailContainerViewController.header.followButton setHidden:[_uid isEqualToString:[UserSession standard].uid]];
    [_detailContainerViewController.header.followButton setTitle:prompt forState:UIControlStateNormal];
}

- (void)showMessagePromptView {
	[_detailContainerViewController.header.messageAvatar sd_setImageWithURL:[NSURL URLWithString:[UserSession standard].notifyUserpic]
														   placeholderImage:[UIImage imageNamed:@"HP-InfectUserDefaultHeader"]];
	_detailContainerViewController.header.messageCountLabel.text = @([UserSession standard].notifyCnt).stringValue;


	[_detailContainerViewController.header.messagePromptView setHidden:([UserSession standard].notifyCnt <= 0) || !_type];
}

#pragma mark - HXProfileDetailContainerViewControllerDelegate Methods
- (void)detailContainerDidScroll:(HXProfileDetailContainerViewController *)controller scrollOffset:(CGPoint)scrollOffset {
    CGFloat scrollThreshold = _detailContainerViewController.header.height - 64.0f;
    CGFloat alpha = scrollOffset.y/scrollThreshold;
    _navigationBar.colorAlpha = alpha;
    _statusBarStyle = ((alpha > 0.1f) ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent);
    [self setNeedsStatusBarAppearanceUpdate];
    
    [_coverContainerViewController scrollPosition:((scrollOffset.y < scrollThreshold) ? UICollectionViewScrollPositionTop : UICollectionViewScrollPositionBottom)];
}

- (void)detailContainer:(HXProfileDetailContainerViewController *)controller takeAction:(HXProfileDetailContainerAction)action {
    switch (action) {
        case HXProfileDetailContainerActionShowMusicDetail: {
            _pushed = YES;
            break;
        }
        case HXProfileDetailContainerActionShowFans: {
            FriendViewController *friendVC = [[FriendViewController alloc] initWithType:UserListViewTypeFans
                                                                                 isHost:_type
                                                                                    uID:_uid
                                                                              fansCount:_fansCount
                                                                         followingCount:_followCount];
            [self.navigationController pushViewController:friendVC animated:YES];
            break;
        }
        case HXProfileDetailContainerActionShowFollow: {
            FriendViewController *friendVC = [[FriendViewController alloc] initWithType:UserListViewTypeFollowing
                                                                                 isHost:_type
                                                                                    uID:_uid
                                                                              fansCount:_fansCount
                                                                         followingCount:_followCount];
            [self.navigationController pushViewController:friendVC animated:YES];
            break;
        }
        case HXProfileDetailContainerActionShoulFollow: {
            if ([UserSession standard].state) {
                [MiaAPIHelper followWithUID:_uid isFollow:!_followState completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
                    [HXAlertBanner showWithMessage:(!_followState ? @"添加关注成功" : @"取消关注成功") tap:nil];
                    [self displayFollowState:!_followState];
                } timeoutBlock:^(MiaRequestItem *requestItem) {
                    [HXAlertBanner showWithMessage:@"请求超时，请重试！" tap:nil];
                }];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedLoginNotification object:nil];
            }
            break;
        }
		case HXProfileDetailContainerActionShowMessageCenter: {
			_pushed = YES;
			HXMessageCenterViewController *messageCenterViewController = [HXMessageCenterViewController instance];
			[self.navigationController pushViewController:messageCenterViewController animated:YES];

			break;
		}
    }
}

#pragma mark - HXNavigationBarDelegate Methods
- (void)navigationBarDidBackAction {
	[_detailContainerViewController stopMusic];
}

@end
