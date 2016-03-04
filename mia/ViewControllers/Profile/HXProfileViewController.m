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
#import "HXProfileNavigationBar.h"
#import "MiaAPIHelper.h"
#import "UIImageView+WebCache.h"
#import "WebSocketMgr.h"
#import "HXAlertBanner.h"
#import "MusicMgr.h"
#import "HXUserSession.h"
#import "HXPlayViewController.h"
#import "FriendViewController.h"
#import "HXMessageCenterViewController.h"

@interface HXProfileViewController () <
HXProfileDetailContainerViewControllerDelegate,
HXProfileNavigationBarDelegate
>
@end

@implementation HXProfileViewController {
    BOOL _hiddenNavigationBar;
    
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
    
    BOOL hidden = _hiddenNavigationBar ?: (self.navigationController.viewControllers.count < 2);
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

#pragma mark - Configure Methods
- (void)loadConfigure {
    _statusBarStyle = UIStatusBarStyleLightContent;
    _detailContainerViewController.header.host = ([[HXUserSession share].uid isEqualToString:_uid]);
}

- (void)viewConfigure {
	_navigationBar.delegate = self;
}

#pragma mark - Private Methods
- (void)fetchProfileData {
    [MiaAPIHelper getUserInfoWithUID:_uid completeBlock:
     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
         if (success) {
             NSDictionary *data = userInfo[MiaAPIKey_Values][@"info"][0];
             HXProfileHeaderModel *model = [HXProfileHeaderModel mj_objectWithKeyValues:data];
             [_detailContainerViewController.header displayWithHeaderModel:model];
             [_coverContainerViewController.avatarBG sd_setImageWithURL:[NSURL URLWithString:model.avatar]];
             [_navigationBar setTitle:model.nickName];
             
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
    _detailContainerViewController.header.follow = state;
}

- (void)displayFansCountWithFollowState:(NSUInteger)state {
    NSUInteger count = state ? 1 : -1;
    _fansCount = _detailContainerViewController.header.fansCountLabel.text.integerValue + count;
    _fansCount = _fansCount ?: 0;
    [_detailContainerViewController.header.fansCountLabel setText:@(_fansCount).stringValue];
}

#pragma mark - HXProfileDetailContainerViewControllerDelegate Methods
- (void)detailContainerDidScroll:(HXProfileDetailContainerViewController *)controller scrollOffset:(CGPoint)scrollOffset {
    CGFloat scrollThreshold = _detailContainerViewController.header.height - 64.0f;
    CGFloat alpha = scrollOffset.y/scrollThreshold;
    _navigationBar.colorAlpha = alpha;
    _statusBarStyle = ((alpha > 0.1f) ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent);
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)detailContainer:(HXProfileDetailContainerViewController *)controller takeAction:(HXProfileDetailContainerAction)action {
    switch (action) {
        case HXProfileDetailContainerActionShowMusicDetail: {
            _hiddenNavigationBar = NO;
            break;
        }
        case HXProfileDetailContainerActionShowFans: {
            _hiddenNavigationBar = YES;
            FriendViewController *friendVC = [[FriendViewController alloc] initWithType:UserListViewTypeFans
                                                                                 isHost:NO
                                                                                    uID:_uid
                                                                              fansCount:_fansCount
                                                                         followingCount:_followCount];
            [self.navigationController pushViewController:friendVC animated:YES];
            break;
        }
        case HXProfileDetailContainerActionShowFollow: {
            _hiddenNavigationBar = YES;
            FriendViewController *friendVC = [[FriendViewController alloc] initWithType:UserListViewTypeFollowing
                                                                                 isHost:NO
                                                                                    uID:_uid
                                                                              fansCount:_fansCount
                                                                         followingCount:_followCount];
            [self.navigationController pushViewController:friendVC animated:YES];
            break;
        }
        case HXProfileDetailContainerActionShoulFollow: {
            switch ([HXUserSession share].userState) {
                case HXUserStateLogout: {
                    [self shouldLogin];
                    break;
                }
                case HXUserStateLogin: {
                    [MiaAPIHelper followWithUID:_uid isFollow:!_followState completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
                        _followState = !_followState;
                        [HXAlertBanner showWithMessage:(_followState ? @"添加关注成功" : @"取消关注成功") tap:nil];
                        [self displayFollowState:_followState];
                        [self displayFansCountWithFollowState:_followState];
                    } timeoutBlock:^(MiaRequestItem *requestItem) {
                        [HXAlertBanner showWithMessage:@"请求超时，请重试" tap:nil];
                    }];
                    break;
                }
            }
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

@end
