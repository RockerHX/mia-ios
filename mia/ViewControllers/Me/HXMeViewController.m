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
#import "UIImageView+WebCache.h"
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
HXMeNavigationBarDelegate
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
    return @"HXMeNavgationController";
}

+ (HXStoryBoardName)storyBoardName {
    return HXStoryBoardNameMe;
}

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

#pragma mark - Configure Methods
- (void)loadConfigure {
    _statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewConfigure {
    _navigationBar.delegate = self;
    [self showMessagePromptView];
}

#pragma mark - Private Methods
- (void)fetchProfileData {
    [MiaAPIHelper getUserInfoWithUID:[HXUserSession share].uid completeBlock:
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
//														   placeholderImage:[UIImage imageNamed:@"HP-InfectUserDefaultHeader"]];
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
- (void)navigationBar:(HXMeNavigationBar *)bar takeAction:(HXMeNavigationBarAction)action {
    switch (action) {
        case HXMeNavigationBarMusic: {
            if ([MusicMgr standard].currentItem) {
                _hiddenNavigationBar = YES;
                UINavigationController *playNavigationController = [HXPlayViewController navigationControllerInstance];
//                HXPlayViewController *playViewController = playNavigationController.viewControllers.firstObject;
                
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

@end
