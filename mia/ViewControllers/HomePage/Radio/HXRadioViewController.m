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
    
    BOOL _canPlay;
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
    _canPlay = YES;
    
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
    _waringLabel.alpha = 0.0f;
    [_helper configWithCarousel:_carousel];
}

#pragma mark - Private Methods
- (void)loadShareList {
	if (_shareListMgr) {
		NSLog(@"auto reconnect did not need to reload data.");
		return;
	}

    _shareListMgr = [ShareListMgr initFromArchive];
    [self reloadLoopPlayerData:YES];
	if ([_shareListMgr isNeedGetNearbyItems]) {
        [self requestNewShares];
	}
}

- (void)cleanShareListUserState {
	[_shareListMgr cleanUserState];
}

- (void)reloadLoopPlayerData:(BOOL)scroll {
    _helper.items = _shareListMgr.shareList;
    if (scroll) {
        [_carousel scrollToItemAtIndex:_shareListMgr.currentIndex animated:NO];
    }
}

- (void)checkIsNeedToGetNewItems {
	if ([_shareListMgr isNeedGetNearbyItems]) {
		[self requestNewShares];
	}
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
                                  [strongSelf reloadLoopPlayerData:NO];
							  } else {
								  id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
								  [[FileLog standard] log:@"getNearbyWithLatitude failed: %@", error];
							  }
						  } timeoutBlock:^(MiaRequestItem *requestItem) {
							  [[FileLog standard] log:@"getNearbyWithLatitude timeout"];
						  }];
}

- (void)viewShouldDisplay {
    if (_helper.items.count > _shareListMgr.currentIndex) {
        if ([[MusicMgr standard] isPlayingWithUrl:((ShareItem *)_helper.items[_shareListMgr.currentIndex]).music.murl]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:HXMusicPlayerMgrDidPlayNotification object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:HXMusicPlayerMgrDidPauseNotification object:nil];
        }
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

- (void)playPrevious {
    [_shareListMgr cursorShiftLeft];
    [_carousel scrollToItemAtIndex:_shareListMgr.currentIndex animated:YES];
}

- (void)playNext {
    [_shareListMgr cursorShiftRight];
    [self checkIsNeedToGetNewItems];
    [_carousel scrollToItemAtIndex:_shareListMgr.currentIndex animated:YES];
}

#pragma mark - SongListPlayerDataSource
- (NSInteger)songListPlayerCurrentItemIndex {
	return _shareListMgr.currentIndex;
}

- (NSInteger)songListPlayerNextItemIndex {
	NSInteger nextIndex = _shareListMgr.currentIndex + 1;
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
    [self playNext];
}

- (void)songListPlayerShouldPlayPrevios {
    [self playPrevious];
}

- (void)songListPlayerShouldPlayNext {
    [self playNext];
}

#pragma mark - HXRadioCarouselHelperDelegate Methods
- (void)helperShouldPlay:(HXRadioCarouselHelper *)helper {
    if (!_canPlay) {
        _canPlay = YES;
        return;
    }
	if ([MusicMgr standard].isInterruption) {
		NSLog(@"helperShouldPlay has been ignored, app is interruption.");
		return;
	}

    _shareListMgr.currentIndex = _carousel.currentItemIndex;
    NSInteger currentIndex = _shareListMgr.currentIndex;
    ShareItem *playItem = _helper.items[currentIndex];
    [self playMusic:playItem];
    [self checkIsNeedToGetNewItems];
    if ([_shareListMgr checkHistoryItemsMaxCount]) {
        _carousel.currentItemIndex = _shareListMgr.currentIndex;
        [self reloadLoopPlayerData:NO];
        _canPlay = NO;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(shouldDisplayInfectUsers:)]) {
        [_delegate shouldDisplayInfectUsers:playItem];
    }
    
	// 更新单条分享的信息
	[MiaAPIHelper getShareById:playItem.sID
				 spID:playItem.spID
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
			 NSArray *flyArray = userInfo[MiaAPIKey_Values][@"data"][@"flyList"];
             
             if ([sID isEqualToString:playItem.sID]) {
                 playItem.isInfected = isInfected;
                 playItem.cComm = [cComm intValue];
                 playItem.cView = [cView intValue];
                 playItem.favorite = [start intValue];
                 playItem.infectTotal = [infectTotal intValue];
                 [playItem parseInfectUsersFromJsonArray:infectArray];
				 [playItem parseFlyCommentsFromJsonArray:flyArray];
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
								   spID:playItem.spID
						  completeBlock:
	 ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
		 if (success) {
			 NSLog(@"viewShareWithLatitude success");
		 } else {
			 NSLog(@"viewShareWithLatitude failed: %@", userInfo[MiaAPIKey_Values][MiaAPIKey_Error]);
		 }
	 } timeoutBlock:^(MiaRequestItem *requestItem) {
		 NSLog(@"viewShareWithLatitude timeout");
	 }];
}

- (void)helperShouldPause:(HXRadioCarouselHelper *)helper {
    [self pauseMusic];
}

- (void)helperDidTaped:(HXRadioCarouselHelper *)helper {
    if (_delegate && [_delegate respondsToSelector:@selector(raidoViewDidTaped)]) {
        [_delegate raidoViewDidTaped];
    }
}

- (void)helperSharerNameTaped:(HXRadioCarouselHelper *)helper {
    if (_delegate && [_delegate respondsToSelector:@selector(userWouldLikeSeeSharerWithItem:)]) {
        [_delegate userWouldLikeSeeSharerWithItem:_helper.items[_shareListMgr.currentIndex]];
    }
}

- (void)helperShareContentTaped:(HXRadioCarouselHelper *)helper {
    if (_delegate && [_delegate respondsToSelector:@selector(userWouldLikeSeeShareDetialWithItem:)]) {
        [_delegate userWouldLikeSeeShareDetialWithItem:_helper.items[_shareListMgr.currentIndex]];
    }
}

- (void)helperStarTapedNeedLogin:(HXRadioCarouselHelper *)helper {
    if (_delegate && [_delegate respondsToSelector:@selector(userStartNeedLogin)]) {
        [_delegate userStartNeedLogin];
    }
}

static CGFloat offsetXThreshold = 60.0f;
- (void)helperScrollNoLastest:(HXRadioCarouselHelper *)helper offsetX:(CGFloat)offsetX {
    CGFloat offset = (offsetX - offsetXThreshold);
    CGFloat logoWidth = _noMoreLogoWidthConstraint.constant;
    if ((offset > 0.0f) && (offset < (logoWidth * 3))) {
        _noMoreLastestLogo.center = CGPointMake((-(logoWidth/2) + offset/3), _noMoreLastestLogo.center.y);
    } else if (offset < 0.0f) {
        _noMoreLastestLogo.center = CGPointMake(-(logoWidth/2), _noMoreLastestLogo.center.y);
    }
    BOOL show = (offset > logoWidth * 2);
    
    _waringLabel.hidden = !show;
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.4f animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf.waringLabel.alpha = show ? 1.0f : 0.0f;
    }];
}

- (void)helperScrollNoNewest:(HXRadioCarouselHelper *)helper offsetX:(CGFloat)offsetX {
    if ([_shareListMgr isEnd]) {
        CGFloat offset = (offsetX - offsetXThreshold);
        CGFloat logoWidth = _noMoreLogoWidthConstraint.constant;
        if ((offset > 0.0f) && (offset < (logoWidth * 3))) {
            _noMoreNewestLogo.center = CGPointMake((SCREEN_WIDTH + (logoWidth/2) - offset/3), _noMoreLastestLogo.center.y);
        } else if (offset < 0.0f) {
            _noMoreNewestLogo.center = CGPointMake(SCREEN_WIDTH + (logoWidth/2), _noMoreLastestLogo.center.y);
        }
    }
}

@end
