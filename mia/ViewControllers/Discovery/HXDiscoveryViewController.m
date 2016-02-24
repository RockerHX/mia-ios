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

@interface HXDiscoveryViewController () <
HXDiscoveryHeaderDelegate,
HXDiscoveryContainerViewControllerDelegate
>

@end

@implementation HXDiscoveryViewController {
    HXDiscoveryContainerViewController *_containerViewController;
    
    ShareListMgr *_shareListMgr;
    
    HXLoadingView *_loadingView;
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
//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
//}
//
//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [[WebSocketMgr standard] watchNetworkStatus];
    [[LocationMgr standard] initLocationMgr];
    [[LocationMgr standard] startUpdatingLocationWithOnceBlock:nil];
}

- (void)viewConfigure {
    _loadingView = [HXLoadingView new];
    [_loadingView showOnViewController:self];
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

#pragma mark - Private Methods
- (void)hiddenLoadingView {
    _loadingView.loadState = HXLoadStateSuccess;
}

- (void)reloadShareList {
    _containerViewController.dataSoure = _shareListMgr.shareList;
}

- (void)checkShouldFetchNewItems {
    if ([_shareListMgr isNeedGetNearbyItems]) {
        [self fetchNewShares];
    }
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
                 return;
             }
             
             [_shareListMgr addSharesWithArray:shareList];
             [self hiddenLoadingView];
             [self reloadShareList];
         } else {
             id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
             [[FileLog standard] log:@"getNearbyWithLatitude failed: %@", error];
         }
     } timeoutBlock:^(MiaRequestItem *requestItem) {
         [[FileLog standard] log:@"getNearbyWithLatitude timeout"];
     }];
}

#pragma mark - HXDiscoveryHeaderDelegate Methods
- (void)discoveryHeader:(HXDiscoveryHeader *)header takeAction:(HXDiscoveryHeaderAction)action {
    switch (action) {
        case HXDiscoveryHeaderActionProfile: {
            ;
            break;
        }
        case HXDiscoveryHeaderActionShare: {
            ;
            break;
        }
    }
}

#pragma mark - HXDiscoveryContainerViewControllerDelegate Methods
- (void)containerViewController:(HXDiscoveryContainerViewController *)container takeAction:(HXDiscoveryCardAction)action {
    switch (action) {
        case HXDiscoveryCardActionSlidePrevious: {
            ;
            break;
        }
        case HXDiscoveryCardActionSlideNext: {
            _shareListMgr.currentIndex = _containerViewController.currentPage;
            
            [self checkShouldFetchNewItems];
            if ([_shareListMgr checkHistoryItemsMaxCount]) {
                _containerViewController.currentPage = _shareListMgr.currentIndex;
            }
            break;
        }
        case HXDiscoveryCardActionPlay: {
#warning Eden
            break;
        }
    }
}

@end
