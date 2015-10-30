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
#import "LocationMgr.h"
#import "HXAppConstants.h"
#import "MusicMgr.h"
#import "SongListPlayer.h"
#import "FileLog.h"

@interface HXRadioViewController () <HXRadioCarouselHelperDelegate, SongListPlayerDelegate, SongListPlayerDataSource> {
    NSMutableArray *_items;
    HXRadioCarouselHelper *_helper;

	ShareListMgr 	*_shareListMgr;
	SongListPlayer	*_songListPlayer;
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
	if (_shareListMgr) {
		NSLog(@"auto reconnect did not need to reload data.");
		return;
	}

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

- (void)playCurrentItems:(NSArray *)items {
	[self updateStatusWithItems:items];
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
							  if (success) {
								  __strong __typeof__(self)strongSelf = weakSelf;
								  NSArray *shareList = userInfo[@"v"][@"data"];
								  if (!shareList) {
									  [[FileLog standard] log:@"getNearbyWithLatitude failed: shareList is nill"];
									  return;
								  }

								  [_shareListMgr addSharesWithArray:shareList];

								  if (_isLoading) {
									  [strongSelf reloadLoopPlayerData];
									  _isLoading = NO;
								  }
							  } else {
								  id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
								  [[FileLog standard] log:@"getNearbyWithLatitude failed: %@", error];
							  }
						  } timeoutBlock:^(MiaRequestItem *requestItem) {
							  [[FileLog standard] log:@"getNearbyWithLatitude timeout"];
						  }];
}

- (void)viewShouldDisplay {
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

	[[MusicMgr standard] setCurrentPlayer:_songListPlayer];
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

- (NSInteger)songListPlayerNextItemIndex {
	NSInteger nextIndex = _shareListMgr.currentItem + 1;
	if (nextIndex >= _shareListMgr.shareList.count) {
		nextIndex = 0;
	}

	return nextIndex;
}

- (MusicItem *)songListPlayerItemAtIndex:(NSInteger)index {
	return [[[_shareListMgr.shareList objectAtIndex:index] music] copy];
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
	}
    
	[_carousel scrollToItemAtIndex:[_helper nextItemIndex] animated:YES];
}

- (void)songListPlayerShouldPlayNext {
	if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
		[_shareListMgr cursorShiftRight];
		[self checkIsNeedToGetNewItems];
		[_shareListMgr checkHistoryItemsMaxCount];
	}

	[_carousel scrollToItemAtIndex:[_helper nextItemIndex] animated:YES];
}

- (void)songListPlayerShouldPlayPrevios {
	if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
		[_shareListMgr cursorShiftLeft];
	}

	[_carousel scrollToItemAtIndex:[_helper previousItemIndex] animated:YES];
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
    if (action != HXRadioCarouselHelperActionPlayCurrent) {
        if (_delegate && [_delegate respondsToSelector:@selector(musicDidChange:)]) {
            ShareItem *currentItem = [_shareListMgr getCurrentItem];
            [_delegate musicDidChange:currentItem];
        }
    }
}

- (void)helperDidChange:(HXRadioCarouselHelper *)helper {
    NSLog(@"change");
    [self reloadLoopPlayerData];
}

- (void)helperShouldPlay:(HXRadioCarouselHelper *)helper {
	[self playMusic:_helper.currentItem];

	// 更新单条分享的信息
	[MiaAPIHelper getShareById:_helper.currentItem.sID completeBlock:
	 ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
		 if (success) {
				NSString *sID = userInfo[MiaAPIKey_Values][@"data"][@"sID"];
				id start = userInfo[MiaAPIKey_Values][@"data"][@"star"];
				id cComm = userInfo[MiaAPIKey_Values][@"data"][@"cComm"];
				id cView = userInfo[MiaAPIKey_Values][@"data"][@"cView"];
				id infectTotal = userInfo[MiaAPIKey_Values][@"data"][@"infectTotal"];
				NSArray *infectArray = userInfo[MiaAPIKey_Values][@"data"][@"infectList"];

				if ([sID isEqualToString:_helper.currentItem.sID]) {
					_helper.currentItem.cComm = [cComm intValue];
					_helper.currentItem.cView = [cView intValue];
					_helper.currentItem.favorite = [start intValue];
					_helper.currentItem.infectTotal = [infectTotal intValue];
					[_helper.currentItem parseInfectUsersFromJsonArray:infectArray];
#warning @andy 更新单条数据后需要刷新下界面
				}
			} else {
				NSLog(@"getShareById failed");
			}
	} timeoutBlock:^(MiaRequestItem *requestItem) {
		NSLog(@"getShareById timeout");
	}];

	// PV上报
	[MiaAPIHelper viewShareWithLatitude:[[LocationMgr standard] currentCoordinate].latitude
							  longitude:[[LocationMgr standard] currentCoordinate].longitude
								address:[[LocationMgr standard] currentAddress]
								   spID:_helper.currentItem.spID
						  completeBlock:
	 ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
		 if (success) {
			 NSLog(@"viewShareWithLatitude success");
		 } else {
			 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
			 NSLog(@"viewShareWithLatitude failed: %@", error);
		 }
	 } timeoutBlock:^(MiaRequestItem *requestItem) {
		 NSLog(@"viewShareWithLatitude timeout");
	 }];
}

- (void)helperShouldPause:(HXRadioCarouselHelper *)helper {
    [self pauseMusic];
}

- (void)helperDidTaped:(HXRadioCarouselHelper *)helper {
//    if (_delegate && [_delegate respondsToSelector:@selector(shouldPushToRadioDetailViewController)]) {
//        [_delegate shouldPushToRadioDetailViewController];
//    }
}

- (void)helperSharerNameTaped:(HXRadioCarouselHelper *)helper {
	if (_delegate && [_delegate respondsToSelector:@selector(userWouldLikeSeeSharerHomePageWithItem:)]) {
		[_delegate userWouldLikeSeeSharerHomePageWithItem:helper.currentItem];
	}
}

- (void)helperStarTapedNeedLogin:(HXRadioCarouselHelper *)helper {
	if (_delegate && [_delegate respondsToSelector:@selector(userStartNeedLogin)]) {
		[_delegate userStartNeedLogin];
	}
}

@end
