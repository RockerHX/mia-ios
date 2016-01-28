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
#import "HXProfileDetailContainerViewController.h"
#import "MiaAPIHelper.h"

@interface HXProfileViewController () <
HXProfileDetailContainerViewControllerDelegate
>
@end

@implementation HXProfileViewController {
    UIStatusBarStyle  _statusBarStyle;
    HXProfileCoverContainerViewController *_coverContainerViewController;
    HXProfileDetailContainerViewController *_detailContainerViewController;
}

#pragma mark - View Controller Life Cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
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
        _detailContainerViewController.delegate = self;
    }
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    [self showHUD];
    [self fetchProfileData];
}

- (void)viewConfigure {
    ;
}

#pragma mark - Private Methods
- (void)fetchProfileData {
    [MiaAPIHelper getUserInfoWithUID:_uid completeBlock:
     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
         if (success) {
             NSString *avatarUrl = userInfo[MiaAPIKey_Values][@"info"][0][@"uimg"];
             NSString *nickName = userInfo[MiaAPIKey_Values][@"info"][0][@"nick"];
             long gender = [userInfo[MiaAPIKey_Values][@"info"][0][@"gender"] intValue];
#warning @andy
             // for test linyehui
             long fansCnt = [userInfo[MiaAPIKey_Values][@"info"][0][@"fansCnt"] intValue];
             long followCnt = [userInfo[MiaAPIKey_Values][@"info"][0][@"followCnt"] intValue];
             long follow = [userInfo[MiaAPIKey_Values][@"info"][0][@"follow"] intValue];	// 0表示没关注，1表示关注，2表示相互关注
             NSArray *imgs = userInfo[MiaAPIKey_Values][@"info"][0][@"background"];
             NSLog(@"user info: %ld, %ld, %ld, %@", fansCnt, followCnt, follow, imgs);
             // end for test
             
             _coverContainerViewController.dataSource = imgs;
//             [_nickNameTextField setText:nickName];
//             _lastNickName = nickName;
//             
//             NSString *avatarUrlWithTime = [NSString stringWithFormat:@"%@?t=%ld", avatarUrl, (long)[[NSDate date] timeIntervalSince1970]];
//             [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrlWithTime]
//                                 placeholderImage:[UIImage imageNamed:@"HP-InfectUserDefaultHeader"]];
//             [self updateGenderLabel:gender];
             [self hiddenHUD];
         } else {
             NSLog(@"getUserInfoWithUID failed");
         }
     } timeoutBlock:^(MiaRequestItem *requestItem) {
         NSLog(@"getUserInfoWithUID timeout");
     }];
}

#pragma mark - HXProfileDetailContainerViewControllerDelegate Methods
static CGFloat scrollThreshold = 135.0f;
- (void)detailContainerDidScroll:(HXProfileDetailContainerViewController *)controller scrollOffset:(CGPoint)scrollOffset {
    CGFloat alpha = scrollOffset.y/scrollThreshold;
    _navigationBar.colorAlpha = alpha;
    _statusBarStyle = ((alpha > 0.1f) ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent);
    [self setNeedsStatusBarAppearanceUpdate];
    
    [_coverContainerViewController scrollPosition:((scrollOffset.y < scrollThreshold) ? UICollectionViewScrollPositionTop : UICollectionViewScrollPositionBottom)];
}

@end
