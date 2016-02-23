//
//  HXDiscoveryViewController.m
//  mia
//
//  Created by miaios on 16/2/16.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXDiscoveryViewController.h"
#import "HXDiscoveryHeader.h"
#import "WebSocketMgr.h"
#import "LocationMgr.h"
#import "ShareListMgr.h"
#import "MiaAPIHelper.h"
#import "FileLog.h"

@interface HXDiscoveryViewController () <
HXDiscoveryHeaderDelegate
>

@end

@implementation HXDiscoveryViewController {
    ShareListMgr *_shareListMgr;
}

#pragma mark - Class Methods
+ (NSString *)navigationControllerIdentifier {
    return @"HXDiscoveryNavgationController";
}

+ (HXStoryBoardName)storyBoardName {
    return HXStoryBoardNameDiscovery;
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
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [self startLoadMusic];
}

#pragma mark - Public Methods
- (void)fetchShareList {
    if (_shareListMgr) {
        NSLog(@"auto reconnect did not need to reload data.");
        return;
    }
    
    _shareListMgr = [ShareListMgr initFromArchive];
//    [self reloadLoopPlayerData:YES];
    if ([_shareListMgr isNeedGetNearbyItems]) {
        [self requestNewShares];
    }
}

#pragma mark - Private Methods
- (void)startLoadMusic {
    [[WebSocketMgr standard] watchNetworkStatus];
    [self initLocationMgr];
}

- (void)initLocationMgr {
    [[LocationMgr standard] initLocationMgr];
    [[LocationMgr standard] startUpdatingLocationWithOnceBlock:nil];
}

- (void)requestNewShares {
    const long kRequestItemCount = 10;
    __weak __typeof__(self)weakSelf = self;
    [MiaAPIHelper getNearbyWithLatitude:[[LocationMgr standard] currentCoordinate].latitude
                              longitude:[[LocationMgr standard] currentCoordinate].longitude
                                  start:1
                                   item:kRequestItemCount
                          completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
                              if (success) {
                                  __strong __typeof__(self)strongSelf = weakSelf;
                                  NSArray *shareList = userInfo[@"v"][@"data"];
                                  if (!shareList.count) {
                                      [[FileLog standard] log:@"getNearbyWithLatitude failed: shareList is nill"];
                                      return;
                                  }
                                  
                                  [strongSelf->_shareListMgr addSharesWithArray:shareList];
//                                  [strongSelf reloadLoopPlayerData:NO];
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

@end
