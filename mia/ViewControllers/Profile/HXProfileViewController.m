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

@interface HXProfileViewController () <
HXProfileDetailContainerViewControllerDelegate
>
@end

@implementation HXProfileViewController {
    BOOL  _pushed;
    UIStatusBarStyle  _statusBarStyle;
    HXProfileCoverContainerViewController *_coverContainerViewController;
    HXProfileDetailContainerViewController *_detailContainerViewController;
}

#pragma mark - View Controller Life Cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:_pushed];
    if (_pushed) {
        _pushed = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (!_pushed) {
        return;
    }
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

- (NSString *)navigationControllerIdentifier {
    return @"HXProfileNavigationController";
}

- (HXStoryBoardName)storyBoardName {
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
        _detailContainerViewController.type = _type;
        _detailContainerViewController.delegate = self;
    }
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    [self showHUD];
    [self fetchProfileData];
}

- (void)viewConfigure {
    _settingButton.hidden = !_type;
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
             NSInteger fansCnt = [userInfo[MiaAPIKey_Values][@"info"][0][@"fansCnt"] integerValue];
             NSInteger followCnt = [userInfo[MiaAPIKey_Values][@"info"][0][@"followCnt"] integerValue];
             NSInteger follow = [userInfo[MiaAPIKey_Values][@"info"][0][@"follow"] integerValue];            // 0表示没关注，1表示关注，2表示相互关注
             NSArray *imgs = userInfo[MiaAPIKey_Values][@"info"][0][@"background"];
             NSLog(@"user info: %ld, %ld, %ld, %@", fansCnt, followCnt, follow, imgs);
             // end for test
             
             _coverContainerViewController.dataSource = imgs;
             
             NSString *avatarUrlWithTime = [NSString stringWithFormat:@"%@?t=%ld", avatarUrl, (long)[[NSDate date] timeIntervalSince1970]];
             [_detailContainerViewController.header.avatar sd_setImageWithURL:[NSURL URLWithString:avatarUrlWithTime]
                                                             placeholderImage:[UIImage imageNamed:@"HP-InfectUserDefaultHeader"]];
             _detailContainerViewController.header.nickNameLabel.text = nickName;
             _detailContainerViewController.header.fansCountLabel.text = @(fansCnt).stringValue;
             _detailContainerViewController.header.followCountLabel.text = @(followCnt).stringValue;
             
             [self hiddenHUD];
         } else {
             NSLog(@"getUserInfoWithUID failed");
         }
     } timeoutBlock:^(MiaRequestItem *requestItem) {
         NSLog(@"getUserInfoWithUID timeout");
     }];
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

- (void)detailContainerWouldLikeShowFans:(HXProfileDetailContainerViewController *)controller {
    FriendViewController *friendVC = [[FriendViewController alloc] initWithType:UserListViewTypeFans
                                                                            uID:_uid];
    [self.navigationController pushViewController:friendVC animated:YES];
}

- (void)detailContainerWouldLikeShowFollow:(HXProfileDetailContainerViewController *)controller {
    FriendViewController *friendVC = [[FriendViewController alloc] initWithType:UserListViewTypeFollowing
                                                                            uID:_uid];
    [self.navigationController pushViewController:friendVC animated:YES];
}

@end
