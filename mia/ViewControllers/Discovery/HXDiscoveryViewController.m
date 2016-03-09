//
//  HXDiscoveryViewController.m
//  mia
//
//  Created by miaios on 16/2/16.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXDiscoveryViewController.h"
#import "HXDiscoveryContainerViewController.h"
#import "HXDiscoveryHeader.h"
#import "WebSocketMgr.h"
#import "LocationMgr.h"
#import "ShareListMgr.h"
#import "MiaAPIHelper.h"
#import "FileLog.h"
#import "HXLoadingView.h"
#import "MusicMgr.h"
#import "HXPlayViewController.h"
#import "HXShareViewController.h"
#import "HXProfileViewController.h"
#import "HXUserSession.h"
#import "HXAlertBanner.h"
#import "HXMusicDetailViewController.h"

@interface HXDiscoveryViewController () <
HXDiscoveryHeaderDelegate,
HXDiscoveryContainerViewControllerDelegate
>

@end

@implementation HXDiscoveryViewController {
    HXLoadingView *_loadingView;
    HXDiscoveryContainerViewController *_containerViewController;
    
    ShareListMgr *_shareListMgr;
    
    BOOL _shouldHiddenNavigationBar;
}

#pragma mark - Class Methods
+ (NSString *)navigationControllerIdentifier {
    return @"HXDiscoveryNavgationController";
}

+ (HXStoryBoardName)storyBoardName {
    return HXStoryBoardNameDiscovery;
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    _containerViewController = segue.destinationViewController;
    _containerViewController.delegate = self;
}

#pragma mark - View Controller Lift Cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:_shouldHiddenNavigationBar animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MusicMgrNotificationPlayerEvent object:nil];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    [[WebSocketMgr standard] watchNetworkStatus];
    [[LocationMgr standard] initLocationMgr];
    [[LocationMgr standard] startUpdatingLocationWithOnceBlock:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationPlayerEvent:) name:MusicMgrNotificationPlayerEvent object:nil];
}

- (void)viewConfigure {
    _loadingView = [HXLoadingView new];
    [_loadingView showOnViewController:self];
}

#pragma mark - Notification Methods
- (void)notificationPlayerEvent:(NSNotification *)notification {
    MiaPlayerEvent event = [notification.userInfo[MusicMgrNotificationKey_PlayerEvent] unsignedIntegerValue];
    
    switch (event) {
        case MiaPlayerEventDidPlay: {
            _header.stateView.state = HXMusicStatePlay;
            break;
        }
        case MiaPlayerEventDidPause:
        case MiaPlayerEventDidCompletion: {
            _header.stateView.state = HXMusicStateStop;
            break;
        }
    }
}

#pragma mark - Public Methods
- (void)fetchShareList {
    if (_shareListMgr) {
        NSLog(@"auto reconnect did not need to reload data.");
        return;
    }
    
    _shareListMgr = [ShareListMgr initFromArchive];
    if ([_shareListMgr isNeedGetNearbyItems]) {
        [self fetchNewShares];
    } else {
        [self hiddenLoadingView];
        [self reloadShareList];
    }
}

- (void)refreshShareItem {
    ShareItem *item = _containerViewController.currentItem;
	if (!item) {
		NSLog(@"refreshShareItem with nil item");
		return;
	}

    [MiaAPIHelper getShareById:item.sID
                          spID:item.spID
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
             
             if ([sID isEqualToString:item.sID]) {
                 item.isInfected = isInfected;
                 item.cComm = [cComm intValue];
                 item.cView = [cView intValue];
                 item.favorite = [start intValue];
                 item.infectTotal = [infectTotal intValue];
                 
                 NSDictionary *shareUserDict = userInfo[MiaAPIKey_Values][@"data"][@"shareUser"];
                 NSDictionary *spaceUserDict = userInfo[MiaAPIKey_Values][@"data"][@"spaceUser"];
                 item.shareUser.follow = [shareUserDict[@"follow"] boolValue];
                 item.spaceUser.follow = [spaceUserDict[@"follow"] boolValue];
                 
                 [item parseInfectUsersFromJsonArray:infectArray];
             }
             [self refreshCard];
         } else {
             NSLog(@"getShareById failed");
         }
     } timeoutBlock:^(MiaRequestItem *requestItem) {
         NSLog(@"getShareById timeout");
     }];
}

#pragma mark - Private Methods
- (void)hiddenLoadingView {
    _loadingView.loadState = HXLoadStateSuccess;
}

- (void)reloadShareList {
    _containerViewController.dataSoure = _shareListMgr.shareList;
    _containerViewController.currentPage = _shareListMgr.currentIndex;
}

- (void)fetchNewShares {
    const long kRequestItemCount = 10;
    [MiaAPIHelper getNearbyWithLatitude:[[LocationMgr standard] currentCoordinate].latitude
                              longitude:[[LocationMgr standard] currentCoordinate].longitude
                                  start:1
                                   item:kRequestItemCount
                          completeBlock:
     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
         if (success) {
             NSArray *shareList = userInfo[@"v"][@"data"];
             if (!shareList.count) {
                 [[FileLog standard] log:@"getNearbyWithLatitude failed: shareList is nill"];
			 } else {
				 [_shareListMgr addSharesWithArray:shareList];
				 [self reloadShareList];
			 }
         } else {
             id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
             [[FileLog standard] log:@"getNearbyWithLatitude failed: %@", error];
         }

         [self hiddenLoadingView];
     } timeoutBlock:^(MiaRequestItem *requestItem) {
         [self hiddenLoadingView];
         [[FileLog standard] log:@"getNearbyWithLatitude timeout"];
     }];
}

- (void)showProfileWithUID:(NSString *)uid {
    HXProfileViewController *profileViewController = [HXProfileViewController instance];
    profileViewController.uid = uid;
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)takeInfectAction {
    switch ([HXUserSession share].userState) {
        case HXUserStateLogout: {
            [self shouldLogin];
            break;
        }
        case HXUserStateLogin: {
            ShareItem *item = _containerViewController.currentItem;
            // 传播出去不需要切换歌曲，需要记录下传播的状态和上报服务器
            [MiaAPIHelper InfectMusicWithLatitude:[[LocationMgr standard] currentCoordinate].latitude
                                        longitude:[[LocationMgr standard] currentCoordinate].longitude
                                          address:[[LocationMgr standard] currentAddress]
                                             spID:item.spID
                                    completeBlock:
             ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
                 if (success) {
                     int isInfected = [userInfo[MiaAPIKey_Values][@"data"][@"isInfected"] intValue];
                     int infectTotal = [userInfo[MiaAPIKey_Values][@"data"][@"infectTotal"] intValue];
                     NSArray *infectArray = userInfo[MiaAPIKey_Values][@"data"][@"infectList"];
                     NSString *spID = [userInfo[MiaAPIKey_Values][@"data"][@"spID"] stringValue];
                     
                     if ([spID isEqualToString:item.spID]) {
                         item.infectTotal = infectTotal;
                         [item parseInfectUsersFromJsonArray:infectArray];
                         item.isInfected = isInfected;

						 [HXAlertBanner showWithMessage:@"妙推成功" tap:nil];
					 } else {
						 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
						 [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
					 }

                     [self refreshCard];
                 } else {
                     NSString *error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
                     [HXAlertBanner showWithMessage:error tap:nil];
                 }
             } timeoutBlock:^(MiaRequestItem *requestItem) {
                 item.isInfected = YES;
                 [HXAlertBanner showWithMessage:@"妙推失败，网络请求超时" tap:nil];
             }];
            break;
        }
    }
}

- (void)refreshCard {
    [_containerViewController.carousel reloadItemAtIndex:_shareListMgr.currentIndex animated:NO];
}

#pragma mark - HXDiscoveryHeaderDelegate Methods
- (void)discoveryHeader:(HXDiscoveryHeader *)header takeAction:(HXDiscoveryHeaderAction)action {
    switch (action) {
        case HXDiscoveryHeaderActionShare: {
			switch ([HXUserSession share].userState) {
				case HXUserStateLogout: {
					[self shouldLogin];
					break;
				}
				case HXUserStateLogin: {
					[self.navigationController pushViewController:[HXShareViewController instance] animated:YES];
					break;
				}
			}
            break;
        }
        case HXDiscoveryHeaderActionMusic: {
            if ([MusicMgr standard].currentItem) {
                _shouldHiddenNavigationBar = YES;
                UINavigationController *playNavigationController = [HXPlayViewController navigationControllerInstance];
//                HXPlayViewController *playViewController = playNavigationController.viewControllers.firstObject;
                
                __weak __typeof__(self)weakSelf = self;
                [self presentViewController:playNavigationController animated:YES completion:^{
                    __strong __typeof__(self)strongSelf = weakSelf;
                    strongSelf->_shouldHiddenNavigationBar = NO;
                }];
            }
            break;
        }
    }
}

#pragma mark - HXDiscoveryContainerViewControllerDelegate Methods
- (void)containerViewController:(HXDiscoveryContainerViewController *)container takeAction:(HXDiscoveryCardAction)action {
    _shareListMgr.currentIndex = container.currentPage;
    
    switch (action) {
        case HXDiscoveryCardActionSlidePrevious: {
            [self refreshShareItem];
            break;
        }
        case HXDiscoveryCardActionSlideNext: {
            [self refreshShareItem];
            if ([_shareListMgr isNeedGetNearbyItems]) {
                [self fetchNewShares];
            }
            if ([_shareListMgr checkHistoryItemsMaxCount]) {
				container.dataSoure = _shareListMgr.shareList;
                container.currentPage = _shareListMgr.currentIndex;
            }
            break;
        }
        case HXDiscoveryCardActionPlay: {
            [[MusicMgr standard] setPlayList:_shareListMgr.shareList hostObject:self];
            [[MusicMgr standard] playWithIndex:_shareListMgr.currentIndex];
            break;
        }
        case HXDiscoveryCardActionShowSharer: {
            [self showProfileWithUID:container.currentItem.shareUser.uid];
            break;
        }
        case HXDiscoveryCardActionShowInfecter: {
            [self showProfileWithUID:container.currentItem.spaceUser.uid];
            break;
        }
        case HXDiscoveryCardActionShowCommenter: {
            NSString *commenterID = container.currentItem.lastComment.uID;
            NSString *userID = [HXUserSession share].uid;
            if (commenterID.length > 0) {
                [self showProfileWithUID:commenterID];
            } else {
                if (userID.length > 0) {
                    [self showProfileWithUID:userID];
                } else {
                    [self shouldLogin];
                }
            }
            break;
        }
        case HXDiscoveryCardActionShowDetail: {
            HXMusicDetailViewController *detailViewController = [HXMusicDetailViewController instance];
            detailViewController.playItem = _containerViewController.currentItem;
            [self.navigationController pushViewController:detailViewController animated:YES];
            break;
        }
        case HXDiscoveryCardActionInfect: {
            [self takeInfectAction];
            break;
        }
        case HXDiscoveryCardActionComment: {
            ;
            break;
        }
    }
}

@end
