//
//  HXRadioViewController.m
//  mia
//
//  Created by miaios on 15/10/10.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXRadioViewController.h"
#import "HXRadioCarouselHelper.h"
#import "ShareListMgr.h"
#import "MiaAPIHelper.h"
//#import "MusicPlayerMgr.h"
#import "LocationMgr.h"
#import "HXAppConstants.h"
#import "MusicMgr.h"
#import "SongListPlayer.h"

@interface HXRadioViewController () <HXRadioCarouselHelperDelegate, SongListPlayerDelegate, SongListPlayerDataSource> {
    NSMutableArray *_items;
    HXRadioCarouselHelper *_helper;

	ShareListMgr 	*_shareListMgr;
	SongListPlayer	*_songListPlayer;
	NSTimer 		*_reportViewsTimer;
	BOOL 			_isLoading;
}

@end

@implementation HXRadioViewController

#pragma mark - Init Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initConfig];
}

#pragma mark - View Controller Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self viewConfig];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	// TODO
	// 当前页面显示的时候获取下服务器这个卡片的最新信息
//	[MiaAPIHelper getShareById:[_shareItem sID] completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
//		[self handleGetSharemWitRet:success userInfo:userInfo];
//	} timeoutBlock:^(MiaRequestItem *requestItem) {
//		NSLog(@"getShareById timeout");
//	}];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self viewShouldDisplay];
}

- (void)dealloc {
	_songListPlayer.dataSource = nil;
	_songListPlayer.delegate = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:HXApplicationDidBecomeActiveNotification object:nil];

	_carousel.delegate = nil;
	_carousel.dataSource = nil;
}

#pragma mark - Config Methods
- (void)initConfig {
	_songListPlayer = [[SongListPlayer alloc] initWithModelID:(long)(__bridge void *)self name:@"HXRadioViewController Song List"];
	_songListPlayer.dataSource = self;
	_songListPlayer.delegate = self;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewShouldDisplay) name:HXApplicationDidBecomeActiveNotification object:nil];

    [self setUpHelper];
}

- (void)setUpHelper {
    _helper = [[HXRadioCarouselHelper alloc] init];
    _helper.delegate = self;
}

- (void)viewConfig {
    [_helper configWithCarousel:_carousel];
}

#pragma mark - Event Response

#pragma mark - Private Methods
- (void)loadShareList {
	_shareListMgr = [ShareListMgr initFromArchive];
	if ([_shareListMgr isNeedGetNearbyItems]) {
        [self requestNewShares];
		_isLoading = YES;
	} else {
		[self reloadLoopPlayerData];
	}
}

- (void)reloadLoopPlayerData {
	ShareItem *currentItem = [_shareListMgr getCurrentItem];
	ShareItem *previousItem = [_shareListMgr getLeftItem];
	ShareItem *nextItem = [_shareListMgr getRightItem];
    
	[self playCurrentItems:@[currentItem, nextItem, previousItem]];
    if (_delegate && [_delegate respondsToSelector:@selector(shouldDisplayInfectUsers:)]) {
        [_delegate shouldDisplayInfectUsers:currentItem];
    }
}

- (void)checkIsNeedToGetNewItems {
	if ([_shareListMgr isNeedGetNearbyItems]) {
		[self requestNewShares];
	}
}

static NSTimeInterval kReportViewsTimeInterval = 15.0f;
- (void)playCurrentItems:(NSArray *)items {
	[_reportViewsTimer invalidate];
    _reportViewsTimer = [self setUpReportTimer];

	[self updateStatusWithItems:items];
}

- (NSTimer *)setUpReportTimer {
    return [NSTimer scheduledTimerWithTimeInterval:kReportViewsTimeInterval target:self selector:@selector(reportViewsTimerAction) userInfo:nil repeats:NO];
}

- (void)updateStatusWithItems:(NSArray *)items {
    _helper.items = items;
}

- (void)requestNewShares {
	const long kRequestItemCount = 10;
    __weak __typeof__(self)weakSelf = self;
	[MiaAPIHelper getNearbyWithLatitude:[[LocationMgr standard] currentCoordinate].latitude
							  longitude:[[LocationMgr standard] currentCoordinate].longitude
								  start:1
								   item:kRequestItemCount
						  completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
                              __strong __typeof__(self)strongSelf = weakSelf;
							  NSArray *shareList = userInfo[@"v"][@"data"];
							  if (!shareList)
								  return;

							  [_shareListMgr addSharesWithArray:shareList];

							  if (_isLoading) {
								  [strongSelf reloadLoopPlayerData];
								  _isLoading = NO;
							  }
						  } timeoutBlock:^(MiaRequestItem *requestItem) {
							  NSLog(@"getNearbyWithLatitude timeout");
						  }];
}

- (void)handleGetSharemWitRet:(BOOL)success userInfo:(NSDictionary *) userInfo {
	if (success) {
        NSString *sID = userInfo[MiaAPIKey_Values][@"data"][@"sID"];
        id start = userInfo[MiaAPIKey_Values][@"data"][@"star"];
        id cComm = userInfo[MiaAPIKey_Values][@"data"][@"cComm"];
        id cView = userInfo[MiaAPIKey_Values][@"data"][@"cView"];
        id infectTotal = userInfo[MiaAPIKey_Values][@"data"][@"infectTotal"];
        NSArray *infectArray = userInfo[MiaAPIKey_Values][@"data"][@"infectList"];
        
        ShareItem *currentItem = _helper.currentItem;
        if ([sID isEqualToString:currentItem.sID]) {
            currentItem.cComm = [cComm intValue];
            currentItem.cView = [cView intValue];
            currentItem.favorite = [start intValue];
            currentItem.infectTotal = [infectTotal intValue];
            [currentItem parseInfectUsersFromJsonArray:infectArray];
            
            if (_delegate && [_delegate respondsToSelector:@selector(shouldDisplayInfectUsers:)]) {
                [_delegate shouldDisplayInfectUsers:currentItem];
            }
        }
        
	} else {
		NSLog(@"handleGetSharemWitRet failed.");
	}
}

- (void)reportViewsTimerAction {
	[MiaAPIHelper viewShareWithLatitude:[[LocationMgr standard] currentCoordinate].latitude
							  longitude:[[LocationMgr standard] currentCoordinate].longitude
								address:[[LocationMgr standard] currentAddress]
								   spID:[_helper.currentItem spID]
						  completeBlock:
	 ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
		 if (success) {
			 [MiaAPIHelper getShareById:[_helper.currentItem sID]
						  completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
							  [self handleGetSharemWitRet:success userInfo:userInfo];
						  } timeoutBlock:^(MiaRequestItem *requestItem) {
							  NSLog(@"getShareById timeout.");
						  }];
		 } else {
			 NSLog(@"view share failed");
		 }
	 } timeoutBlock:^(MiaRequestItem *requestItem) {
		 NSLog(@"view share timeout");
	 }];
}

- (void)viewShouldDisplay {
	[MiaAPIHelper getShareById:[_helper.currentItem sID]
				 completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
					 [self handleGetSharemWitRet:success userInfo:userInfo];
				 } timeoutBlock:^(MiaRequestItem *requestItem) {
					 NSLog(@"getShareById timeout @viewShouldDisplay");
				 }];

	if ([[MusicMgr standard] isPlayingWithUrl:_helper.currentItem.music.murl]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:HXMusicPlayerMgrDidPlayNotification object:nil];
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:HXMusicPlayerMgrDidPauseNotification object:nil];
	}
}

#pragma mark - Audio Operations
- (void)playMusic:(ShareItem *)item {
	MusicItem *musicItem = [item.music copy];
	if (!musicItem.murl || !musicItem.name || !musicItem.singerName) {
		NSLog(@"Music is nil, stop play it.");
		return;
	}

	[[MusicMgr standard] setListPlayer:_songListPlayer];
	[_songListPlayer playWithMusicItem:musicItem];
}

- (void)pauseMusic {
	[_songListPlayer pause];
}

- (void)stopMusic {
	[_songListPlayer stop];
}

#pragma mark - SongListPlayerDataSource
- (NSInteger)songListPlayerCurrentItemIndex {
	return _shareListMgr.currentItem;
}

- (MusicItem *)songListPlayerItemAtIndex:(NSInteger)index {
	return [[_shareListMgr getCurrentItem].music copy];
}

#pragma mark - SongListPlayerDelegate
- (void)songListPlayerDidPlay {
	[[NSNotificationCenter defaultCenter] postNotificationName:HXMusicPlayerMgrDidPlayNotification object:nil];
}

- (void)songListPlayerDidPause {
	[[NSNotificationCenter defaultCenter] postNotificationName:HXMusicPlayerMgrDidPauseNotification object:nil];
}

- (void)songListPlayerDidCompletion {
	if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
		[_shareListMgr cursorShiftRight];
		[self checkIsNeedToGetNewItems];
		[_shareListMgr checkHistoryItemsMaxCount];

		MusicItem *musicItem = [[_shareListMgr getCurrentItem].music copy];
		[_songListPlayer playWithMusicItem:musicItem];
	}

	[_carousel scrollToItemAtIndex:[_helper nextItemIndex] animated:YES];
}

#pragma mark - HXRadioCarouselHelperDelegate Methods
- (void)helper:(HXRadioCarouselHelper *)helper shouldChangeMusic:(HXRadioCarouselHelperAction)action {
    switch (action) {
        case HXRadioCarouselHelperActionPlayPrevious: {
            NSLog(@"Previous");
            _helper.warp = [_shareListMgr cursorShiftLeft];
			[_shareListMgr checkHistoryItemsMaxCount];
            break;
        }
        case HXRadioCarouselHelperActionPlayCurrent: {
            NSLog(@"Current");
            break;
        }
        case HXRadioCarouselHelperActionPlayNext: {
            NSLog(@"Next");
			if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
				_helper.warp = [_shareListMgr cursorShiftRight];
				[self checkIsNeedToGetNewItems];
				[_shareListMgr checkHistoryItemsMaxCount];
			}
            break;
        }
    }
}

- (void)helperDidChange:(HXRadioCarouselHelper *)helper {
    NSLog(@"change");
    [self reloadLoopPlayerData];
}

- (void)helperShouldPlay:(HXRadioCarouselHelper *)helper {
	[self playMusic:_helper.currentItem];
}

- (void)helperShouldPause:(HXRadioCarouselHelper *)helper {
    [self pauseMusic];
}

- (void)helperDidTaped:(HXRadioCarouselHelper *)helper {
    if (_delegate && [_delegate respondsToSelector:@selector(shouldPushToRadioDetailViewController)]) {
        [_delegate shouldPushToRadioDetailViewController];
    }
}

- (void)helperSharerNameTaped:(HXRadioCarouselHelper *)helper {
	if (_delegate && [_delegate respondsToSelector:@selector(userWouldLikeSeeSharerHomePageWithItem:)]) {
		[_delegate userWouldLikeSeeSharerHomePageWithItem:helper.currentItem];
	}
}

- (void)helperStarTapedNeedLogin:(HXRadioCarouselHelper *)helper {
	if (_delegate && [_delegate respondsToSelector:@selector(userStarNeedLogin)]) {
		[_delegate userStarNeedLogin];
	}
}

@end
