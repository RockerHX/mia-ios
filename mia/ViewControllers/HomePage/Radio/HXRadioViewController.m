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
#import "MusicPlayerMgr.h"

@interface HXRadioViewController () <HXRadioCarouselHelperDelegate> {
    NSMutableArray *_items;
    HXRadioCarouselHelper *_helper;

	ShareListMgr 	*_shareListMgr;
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

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MusicPlayerMgrNotificationDidPlay object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MusicPlayerMgrNotificationDidPause object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MusicPlayerMgrNotificationCompletion object:nil];

	_carousel.delegate = nil;
	_carousel.dataSource = nil;
}

#pragma mark - Config Methods
- (void)initConfig {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationMusicPlayerMgrDidPlay:) name:MusicPlayerMgrNotificationDidPlay object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationMusicPlayerMgrDidPause:) name:MusicPlayerMgrNotificationDidPause object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationMusicPlayerMgrCompletion:) name:MusicPlayerMgrNotificationCompletion object:nil];

    [self setUpHelper];
}

- (void)setUpHelper {
    _helper = [[HXRadioCarouselHelper alloc] init];
    _helper.delegate = self;
}

- (void)viewConfig {
    [_helper configWithCarousel:_carousel];
}

#pragma mark - Notification
- (void)notificationMusicPlayerMgrDidPlay:(NSNotification *)notification {
	long modelID = [[notification userInfo][MusicPlayerMgrNotificationKey_ModelID] longValue];
	if (modelID != (long)(__bridge void *)self) {
		NSLog(@"skip other model's notification: MusicPlayerMgrDidPlay");
		return;
	}

//	[_playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
}

- (void)notificationMusicPlayerMgrDidPause:(NSNotification *)notification {
	long modelID = [[notification userInfo][MusicPlayerMgrNotificationKey_ModelID] longValue];
	if (modelID != (long)(__bridge void *)self) {
		NSLog(@"skip other model's notification: notificationMusicPlayerMgrDidPause");
		return;
	}

//	[_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
}

- (void)notificationMusicPlayerMgrCompletion:(NSNotification *)notification {
	long modelID = [[notification userInfo][MusicPlayerMgrNotificationKey_ModelID] longValue];
	if (modelID != (long)(__bridge void *)self) {
		NSLog(@"skip other model's notification: notificationMusicPlayerMgrCompletion");
		return;
	}
	[_carousel scrollToItemAtIndex:[_helper nextItemIndex] animated:YES];

//	if (_customDelegate) {
//		[_customDelegate playerViewPlayCompletion];
//	}
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

	//[_loopPlayerView getLeftPlayerView].shareItem = leftItem;
	//[_loopPlayerView getRightPlayerView].shareItem = rightItem;
}

- (void)checkIsNeedToGetNewItems {
	if ([_shareListMgr isNeedGetNearbyItems]) {
		[self requestNewShares];
	}
}

- (ShareItem *)currentShareItem {
	return nil; // TODO
//	return [[_loopPlayerView getCurrentPlayerView] shareItem];
}

static NSTimeInterval kReportViewsTimeInterval = 15.0f;
- (void)playCurrentItems:(NSArray *)items {
//	[[_loopPlayerView getCurrentPlayerView] playMusic];
//	[_radioViewDelegate radioViewStartPlayItem];

	[_reportViewsTimer invalidate];
    _reportViewsTimer = [self setUpReportTimer];

	[self updateStatusWithItems:items];
}

- (NSTimer *)setUpReportTimer {
    return [NSTimer scheduledTimerWithTimeInterval:kReportViewsTimeInterval target:self selector:@selector(reportViewsTimerAction) userInfo:nil repeats:NO];
}

- (void)updateStatusWithItems:(NSArray *)items {
    NSLog(@"updateStatusWithItems");
    _helper.items = items;
}

- (void)requestNewShares {
	const long kRequestItemCount = 10;
    __weak __typeof__(self)weakSelf = self;
	[MiaAPIHelper getNearbyWithLatitude:0// TODO [_radioViewDelegate radioViewCurrentCoordinate].latitude
							  longitude:0// TODO [_radioViewDelegate radioViewCurrentCoordinate].longitude
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
		long start = [userInfo[MiaAPIKey_Values][@"data"][@"star"] intValue];
		id cComm = userInfo[MiaAPIKey_Values][@"data"][@"cComm"];
		id cView = userInfo[MiaAPIKey_Values][@"data"][@"cView"];

		// TODO
		//ShareItem *currentItem = [_loopPlayerView getCurrentPlayerView].shareItem;
		ShareItem *currentItem = nil;
		if ([sID isEqualToString:currentItem.sID]) {
			currentItem.cComm = [cComm intValue];
			currentItem.cView = [cView intValue];
			currentItem.favorite = start;
//			[self updateStatusWithItem:currentItem];
		}
	} else {
		NSLog(@"handleGetSharemWitRet failed.");
	}
}

- (void)reportViewsTimerAction {
	[MiaAPIHelper viewShareWithLatitude:0 // TODO [_radioViewDelegate radioViewCurrentCoordinate].latitude
							  longitude:0 // TODO [_radioViewDelegate radioViewCurrentCoordinate].longitude
								address:nil // TODO [_radioViewDelegate radioViewCurrentAddress]
								   spID:[[self currentShareItem] spID]
						  completeBlock:
	 ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
		 if (success) {
			 [MiaAPIHelper getShareById:[[self currentShareItem] sID]
						  completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
							  [self handleGetSharemWitRet:success userInfo:userInfo];
						  } timeoutBlock:^(MiaRequestItem *requestItem) {
							  NSLog(@"handleGetSharemWitRet failed.");
						  }];
		 } else {
			 NSLog(@"view share failed");
		 }
	 } timeoutBlock:^(MiaRequestItem *requestItem) {
		 NSLog(@"view share timeout");
	 }];
}

- (void)spreadFeed {
	NSLog(@"#swipe# up spred");
	// 传播出去不需要切换歌曲，需要记录下传播的状态和上报服务器
	[MiaAPIHelper InfectMusicWithLatitude:0// TODO [_radioViewDelegate radioViewCurrentCoordinate].latitude
								longitude:0// TODO [_radioViewDelegate radioViewCurrentCoordinate].longitude
								  address:nil// TODO [_radioViewDelegate radioViewCurrentAddress]
									 spID:[[self currentShareItem] spID]
							completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
								NSLog(@"InfectMusic %d", success);
							} timeoutBlock:^(MiaRequestItem *requestItem) {
								NSLog(@"InfectMusic timeout");
							}];
}

- (void)notifySwipeLeft {
	NSLog(@"#swipe# left");
	// 向左滑动，右侧的卡片需要补充

	// 停止当前，并标记为已读，检查下历史记录是否超出最大个数
	//[[_loopPlayerView getLeftPlayerView] pauseMusic];
	//[_loopPlayerView getLeftPlayerView].shareItem.unread = NO;

	[_shareListMgr checkHistoryItemsMaxCount];

	// 补充一条右边的卡片
	if ([_shareListMgr cursorShiftRight]) {
//		ShareItem *newItem = [_shareListMgr getRightItem];
		// TODO
		//[_loopPlayerView getRightPlayerView].shareItem = newItem;

		// 播放当前卡片上的歌曲
		//[self playCurrentItem:[_loopPlayerView getCurrentPlayerView].shareItem];

		// 检查是否需要获取新的数据
		[self checkIsNeedToGetNewItems];
	} else {
		NSLog(@"shift cursor to right failed.");
		// 检查是否需要获取新的数据
		[self checkIsNeedToGetNewItems];
	}
}

- (void)notifySwipeRight {
	NSLog(@"#swipe# right");
	// 向右滑动，左侧的卡片需要补充

	// 停止当前，这个方向的歌曲都是已读的，所以不需要再标记为已读
	//[[_loopPlayerView getRightPlayerView] pauseMusic];

	// 补充一条左边的卡片
	if ([_shareListMgr cursorShiftLeft]) {
//		ShareItem *newItem = [_shareListMgr getLeftItem];
//		[_loopPlayerView getLeftPlayerView].shareItem = newItem;

		// 播放当前卡片上的歌曲
//		[self playCurrentItem:[_loopPlayerView getCurrentPlayerView].shareItem];

		// 检查是否需要获取新的数据
		[self checkIsNeedToGetNewItems];
	} else {
		NSLog(@"shift cursor to left failed.");
	}
}

- (void)loopPlayerViewPlayCompletion {
	NSLog(@"#swipe# completion");
	// 播放完成自动下一首，用右边的卡片替换当前卡片，并用新卡片填充右侧的卡片

	// 停止当前，并标记为已读，检查下历史记录是否超出最大个数
//	[[_loopPlayerView getCurrentPlayerView] pauseMusic];
//	[_loopPlayerView getCurrentPlayerView].shareItem.unread = NO;
	[_shareListMgr checkHistoryItemsMaxCount];

	// 用当前的卡片内容替代左边的卡片内容
	//	[_loopPlayerView getLeftPlayerView].shareItem = [_loopPlayerView getCurrentPlayerView].shareItem;
	// 用右边的卡片内容替代当前的卡片内容
//	[_loopPlayerView getCurrentPlayerView].shareItem = [_loopPlayerView getRightPlayerView].shareItem;

	// 更新右边的卡片内容
	if ([_shareListMgr cursorShiftRight]) {
//		ShareItem *newItem = [_shareListMgr getRightItem];
//		[_loopPlayerView getRightPlayerView].shareItem = newItem;

		// 播放当前卡片上的歌曲
//		[self playCurrentItem:[_loopPlayerView getCurrentPlayerView].shareItem];

		// 检查是否需要获取新的数据
		[self checkIsNeedToGetNewItems];
	} else {
		NSLog(@"play completion failed.");
	}
}

#pragma mark - Audio Operations
- (void)playMusic:(ShareItem *)item {
	NSString *musicUrl = [[item music] murl];
	NSString *musicTitle = [[item music] name];
	NSString *musicArtist = [[item music] singerName];

	if (!musicUrl || !musicTitle || !musicArtist) {
		NSLog(@"Music is nil, stop play it.");
		return;
	}

	//[_playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
	[[MusicPlayerMgr standard] playWithModelID:(long)(__bridge void *)self url:musicUrl title:musicTitle artist:musicArtist];
}

- (void)pauseMusic {
	//[_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
	[[MusicPlayerMgr standard] pause];
}

- (void)stopMusic {
	//[_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
	[[MusicPlayerMgr standard] stop];
}

#pragma mark - HXRadioCarouselHelperDelegate Methods
- (void)helper:(HXRadioCarouselHelper *)helper shouldChangeMusic:(HXRadioCarouselHelperAction)action {
    switch (action) {
        case HXRadioCarouselHelperActionPlayPrevious: {
            NSLog(@"Previous");
            _helper.warp = [_shareListMgr cursorShiftLeft];
            break;
        }
        case HXRadioCarouselHelperActionPlayCurrent: {
            NSLog(@"Current");
            break;
        }
        case HXRadioCarouselHelperActionPlayNext: {
            NSLog(@"Next");
            _helper.warp = [_shareListMgr cursorShiftRight];
			[self checkIsNeedToGetNewItems];
            break;
        }
    }
}

- (void)helperDidChange:(HXRadioCarouselHelper *)helper {
    NSLog(@"change");
    [self reloadLoopPlayerData];
}

- (void)helperDidTaped:(HXRadioCarouselHelper *)helper {
    NSLog(@"Taped");
}

- (void)helperShouldPlay:(HXRadioCarouselHelper *)helper {
	[self playMusic:[helper currentItem]];
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
