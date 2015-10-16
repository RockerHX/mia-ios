//
//  RadioView.m
//  mia
//
//  Created by linyehui on 2015/09/09.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "RadioView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "UIImage+ColorToImage.h"
#import "MIAButton.h"
#import "MIALabel.h"
#import "MusicPlayerMgr.h"
#import "ShareListMgr.h"
#import "MiaAPIHelper.h"
#import "WebSocketMgr.h"
#import "ShareItem.h"
#import "LoopPlayerView.h"
#import "UserSession.h"
#import "LoginViewController.h"

static const CGFloat kPlayerMarginTop			= 90;
static const CGFloat kPlayerHeight				= 300;

static const CGFloat kFavoriteMarginBottom 		= 80;
static const CGFloat kFavoriteWidth 			= 25;
static const CGFloat kFavoriteHeight 			= 25;

@interface RadioView () <LoopPlayerViewDelegate>

@end

@implementation RadioView {
	ShareListMgr 	*_shareListMgr;
	LoopPlayerView	*_loopPlayerView;
	MIAButton		*_favoriteButton;
	MIALabel		*_commentLabel;
	MIALabel		*_viewsLabel;
	MIALabel		*_locationLabel;
	NSTimer			*_progressTimer;
	NSTimer 		*_reportViewsTimer;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self){
		self.userInteractionEnabled = YES;
//		self.backgroundColor = [UIColor redColor];

		[self initUI];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWebSocketDidReceiveMessage:) name:WebSocketMgrNotificationDidReceiveMessage object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationMusicPlayerMgrDidPlay:) name:MusicPlayerMgrNotificationDidPlay object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationMusicPlayerMgrDidPause:) name:MusicPlayerMgrNotificationDidPause object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationMusicPlayerMgrCompletion:) name:MusicPlayerMgrNotificationCompletion object:nil];
}

	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebSocketMgrNotificationDidReceiveMessage object:nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MusicPlayerMgrNotificationDidPlay object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MusicPlayerMgrNotificationDidPause object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MusicPlayerMgrNotificationCompletion object:nil];
}

- (void)initUI {
	_loopPlayerView = [[LoopPlayerView alloc] initWithFrame:CGRectMake(0, kPlayerMarginTop, self.frame.size.width, kPlayerHeight)];
	_loopPlayerView.loopPlayerViewDelegate = self;
	[self addSubview:_loopPlayerView];

	_favoriteButton = [[MIAButton alloc] initWithFrame:CGRectMake(self.bounds.size.width / 2 - kFavoriteWidth / 2,
																 self.bounds.size.height - kFavoriteMarginBottom - kFavoriteHeight,
																 kFavoriteWidth,
																 kFavoriteHeight)
										  titleString:nil
										   titleColor:nil
												 font:nil
											  logoImg:nil
									  backgroundImage:nil];
	[_favoriteButton setImage:[UIImage imageNamed:@"favorite_white"] forState:UIControlStateNormal];
	[_favoriteButton addTarget:self action:@selector(favoriteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_favoriteButton];

	[self initBottomView];
}

- (void)initBottomView {
	static const CGFloat kBottomViewHeight				= 35;
	static const CGFloat kBottomButtonMarginBottom		= 20;
	static const CGFloat kBottomButtonWidth				= 15;
	static const CGFloat kBottomButtonHeight			= 15;
	static const CGFloat kCommentImageMarginLeft		= 20;
	static const CGFloat kViewsImageMarginLeft			= 60;
	static const CGFloat kLocationImageMarginRight		= 1;
	static const CGFloat kLocationLabelMarginRight		= 20;
	static const CGFloat kLocationLabelWidth			= 80;

	static const CGFloat kCommentLabelMarginLeft		= 2;
	static const CGFloat kBottomLabelMarginBottom		= 20;
	static const CGFloat kBottomLabelHeight				= 15;
	static const CGFloat kCommentLabelWidth				= 20;

	static const CGFloat kViewsLabelMarginLeft			= 2;
	static const CGFloat kViewsLabelWidth				= 20;

	UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - kBottomViewHeight, self.bounds.size.width, kBottomViewHeight)];
	//bottomView.backgroundColor = [UIColor redColor];
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bottomViewTouchAction:)];
	[bottomView addGestureRecognizer:tap];
	[self addSubview:bottomView];

	UIImageView *commentsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kCommentImageMarginLeft,
																				   bottomView.bounds.size.height - kBottomButtonMarginBottom - kBottomButtonHeight,
																				   kBottomButtonWidth,
																				   kBottomButtonHeight)];
	[commentsImageView setImage:[UIImage imageNamed:@"comments"]];
	[bottomView addSubview:commentsImageView];

	_commentLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kCommentImageMarginLeft + kBottomButtonWidth + kCommentLabelMarginLeft,
															  bottomView.bounds.size.height - kBottomLabelMarginBottom - kBottomLabelHeight,
															  kCommentLabelWidth,
															  kBottomLabelHeight)
											  text:@""
											  font:UIFontFromSize(8.0f)
										 textColor:[UIColor grayColor]
									 textAlignment:NSTextAlignmentLeft
									   numberLines:1];
	//commentLabel.backgroundColor = [UIColor redColor];
	[bottomView addSubview:_commentLabel];

	UIImageView *viewsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kViewsImageMarginLeft,
																				bottomView.bounds.size.height - kBottomButtonMarginBottom - kBottomButtonHeight,
																				kBottomButtonWidth,
																				kBottomButtonHeight)];
	[viewsImageView setImage:[UIImage imageNamed:@"views"]];
	[bottomView addSubview:viewsImageView];

	_viewsLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kViewsImageMarginLeft + kBottomButtonWidth + kViewsLabelMarginLeft,
															bottomView.bounds.size.height - kBottomLabelMarginBottom - kBottomLabelHeight,
															kViewsLabelWidth,
															kBottomLabelHeight)
											text:@""
											font:UIFontFromSize(8.0f)
									   textColor:[UIColor grayColor]
								   textAlignment:NSTextAlignmentLeft
									 numberLines:1];
	//viewsLabel.backgroundColor = [UIColor redColor];
	[bottomView addSubview:_viewsLabel];

	UIImageView *locationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(bottomView.bounds.size.width - kLocationLabelMarginRight - kLocationLabelWidth - kLocationImageMarginRight - kBottomButtonWidth,
																				   bottomView.bounds.size.height - kBottomButtonMarginBottom - kBottomButtonHeight,
																				   kBottomButtonWidth,
																				   kBottomButtonHeight)];
	[locationImageView setImage:[UIImage imageNamed:@"location"]];
	[bottomView addSubview:locationImageView];

	_locationLabel = [[MIALabel alloc] initWithFrame:CGRectMake(bottomView.bounds.size.width - kLocationLabelMarginRight - kLocationLabelWidth,
															   bottomView.bounds.size.height - kBottomLabelMarginBottom - kBottomLabelHeight,
															   kLocationLabelWidth,
															   kBottomLabelHeight)
											   text:@""
											   font:UIFontFromSize(8.0f)
									   textColor:[UIColor grayColor]
								   textAlignment:NSTextAlignmentLeft
									 numberLines:1];
	//locationLabel.backgroundColor = [UIColor redColor];
	[bottomView addSubview:_locationLabel];
}

- (void)loadShareList {
	_shareListMgr = [ShareListMgr initFromArchive];
	if ([_shareListMgr isNeedGetNearbyItems]) {
		_isLoading = YES;
	} else {
		[self reloadLoopPlayerData];
	}
}

- (void)reloadLoopPlayerData {
	ShareItem *currentItem = [_shareListMgr getCurrentItem];
	ShareItem *leftItem = [_shareListMgr getLeftItem];
	ShareItem *rightItem = [_shareListMgr getRightItem];

	[_loopPlayerView getCurrentPlayerView].shareItem = currentItem;
	[self playCurrentItem:currentItem];

	[_loopPlayerView getLeftPlayerView].shareItem = leftItem;
	[_loopPlayerView getRightPlayerView].shareItem = rightItem;
}

- (void)checkIsNeedToGetNewItems {
	if ([_shareListMgr isNeedGetNearbyItems]) {
		[self requestNewShares];
	}
}

- (ShareItem *)currentShareItem {
	return [[_loopPlayerView getCurrentPlayerView] shareItem];
}

- (void)playCurrentItem:(ShareItem *)item {
	[[_loopPlayerView getCurrentPlayerView] playMusic];
	[_radioViewDelegate radioViewStartPlayItem];

	[_reportViewsTimer invalidate];
	const NSTimeInterval kReportViewsTimeInterval = 15;
	_reportViewsTimer = [NSTimer scheduledTimerWithTimeInterval:kReportViewsTimeInterval
														 target:self
													   selector:@selector(reportViewsTimerAction)
													   userInfo:nil
														repeats:NO];

	[self updateStatusWithItem:item];
}

- (void)updateStatusWithItem:(ShareItem *)item {
	[_commentLabel setText: 0 == [item cComm] ? @"" : NSStringFromInt([item cComm])];
	[_viewsLabel setText: 0 == [item cView] ? @"" : NSStringFromInt([item cView])];
	[_locationLabel setText:[item sAddress]];
	[self updateShareButtonWithIsFavorite:item.favorite];
}

- (void)updateShareButtonWithIsFavorite:(BOOL)isFavorite {
	if (isFavorite) {
		[_favoriteButton setImage:[UIImage imageNamed:@"favorite_red"] forState:UIControlStateNormal];
	} else {
		[_favoriteButton setImage:[UIImage imageNamed:@"favorite_white"] forState:UIControlStateNormal];
	}
}

#pragma mark - Notification

-(void)notificationWebSocketDidReceiveMessage:(NSNotification *)notification {
	NSString *command = [notification userInfo][MiaAPIKey_ServerCommand];
	id ret = [notification userInfo][MiaAPIKey_Values][MiaAPIKey_Return];

//	NSLog(@"command:%@, ret:%d", command, [ret intValue]);

	if ([command isEqualToString:MiaAPICommand_User_PostInfectm]) {
		[self handleInfectMusicWitRet:[ret intValue] userInfo:[notification userInfo]];
	} else if ([command isEqualToString:MiaAPICommand_User_PostSkipm]) {
		[self handleSkipMusicWitRet:[ret intValue] userInfo:[notification userInfo]];
	} else if ([command isEqualToString:MiaAPICommand_User_PostFavorite]) {
		[self handleFavoriteWitRet:[ret intValue] userInfo:[notification userInfo]];
	} else if ([command isEqualToString:MiaAPICommand_User_PostViewm]) {
		[self handlePostViewmWitRet:[ret intValue] userInfo:[notification userInfo]];
	}
}

- (void)notificationMusicPlayerMgrDidPlay:(NSNotification *)notification {
	[_loopPlayerView notifyMusicPlayerMgrDidPlay];
}

- (void)notificationMusicPlayerMgrDidPause:(NSNotification *)notification {
	[_loopPlayerView notifyMusicPlayerMgrDidPause];
}

- (void)notificationMusicPlayerMgrCompletion:(NSNotification *)notification {
	NSLog(@"#swipe# completion");
	// 播放完成自动下一首，用右边的卡片替换当前卡片，并用新卡片填充右侧的卡片

	// 停止当前，并标记为已读，检查下历史记录是否超出最大个数
	[[_loopPlayerView getCurrentPlayerView] pauseMusic];
	[_loopPlayerView getCurrentPlayerView].shareItem.unread = NO;
	[_shareListMgr checkHistoryItemsMaxCount];

	// 用当前的卡片内容替代左边的卡片内容
	[_loopPlayerView getLeftPlayerView].shareItem = [_loopPlayerView getCurrentPlayerView].shareItem;
	// 用右边的卡片内容替代当前的卡片内容
	[_loopPlayerView getCurrentPlayerView].shareItem = [_loopPlayerView getRightPlayerView].shareItem;

	// 更新右边的卡片内容
	if ([_shareListMgr cursorShiftRight]) {
		ShareItem *newItem = [_shareListMgr getRightItem];
		[_loopPlayerView getRightPlayerView].shareItem = newItem;

		// 播放当前卡片上的歌曲
		[self playCurrentItem:[_loopPlayerView getCurrentPlayerView].shareItem];

		// 检查是否需要获取新的数据
		[self checkIsNeedToGetNewItems];
	} else {
		NSLog(@"play completion failed.");
		// TODO 这种情况应该从界面上禁止他翻页
	}
}

#pragma mark - received message from websocket

- (void)handleInfectMusicWitRet:(int)ret userInfo:(NSDictionary *) userInfo {
	if (0 == ret) {
		NSLog(@"report infect music successed.");
	} else {
		NSLog(@"report infect music failed.");
	}
}

- (void)handleSkipMusicWitRet:(int)ret userInfo:(NSDictionary *) userInfo {
	if (0 == ret) {
		NSLog(@"report skip music successed.");
	} else {
		NSLog(@"report skip music failed.");
	}
}

- (void)handleFavoriteWitRet:(int)ret userInfo:(NSDictionary *) userInfo {
	if (0 == ret) {
		id act = userInfo[MiaAPIKey_Values][@"act"];
		id sID = userInfo[MiaAPIKey_Values][@"id"];
		if ([[self currentShareItem].sID integerValue] == [sID intValue]) {
			[self currentShareItem].favorite = [act intValue];
			[self updateShareButtonWithIsFavorite:[self currentShareItem].favorite];
		}
	} else {
		NSLog(@"favorite music failed.");
	}
}

- (void)handlePostViewmWitRet:(int)ret userInfo:(NSDictionary *) userInfo {
	if (0 == ret) {
		[MiaAPIHelper getShareById:[[self currentShareItem] sID]
		 completeBlock:^(MiaRequestItem *requestItem, BOOL isSuccessed, NSDictionary *userInfo) {
			 [self handleGetSharemWitRet:isSuccessed userInfo:userInfo];
		 } timeoutBlock:^(MiaRequestItem *requestItem) {
			 NSLog(@"handleGetSharemWitRet failed.");
		 }];
	} else {
		NSLog(@"handlePostViewmWitRet failed.");
	}
}

- (void)handleGetSharemWitRet:(BOOL)isSuccessed userInfo:(NSDictionary *) userInfo {
	if (isSuccessed) {
		//"v":{"ret":0, "data":{"sID", "star": 1, "cComm":2, "cView": 2}}}
		NSString *sID = userInfo[MiaAPIKey_Values][@"data"][@"sID"];
		long start = [userInfo[MiaAPIKey_Values][@"data"][@"star"] intValue];
		id cComm = userInfo[MiaAPIKey_Values][@"data"][@"cComm"];
		id cView = userInfo[MiaAPIKey_Values][@"data"][@"cView"];

		ShareItem *currentItem = [_loopPlayerView getCurrentPlayerView].shareItem;
		if ([sID isEqualToString:currentItem.sID]) {
			currentItem.cComm = [cComm intValue];
			currentItem.cView = [cView intValue];
			currentItem.favorite = start;
			[self updateStatusWithItem:currentItem];
		}

		//NSLog(@"%@, %ld, %@, %@", sID, start, cComm, cView);
	} else {
		NSLog(@"handleGetSharemWitRet failed.");
	}
}

- (void)requestNewShares {
	const long kRequestItemCount = 10;
	[MiaAPIHelper getNearbyWithLatitude:[_radioViewDelegate radioViewCurrentCoordinate].latitude
							  longitude:[_radioViewDelegate radioViewCurrentCoordinate].longitude
								  start:1
								   item:kRequestItemCount
	 completeBlock:^(MiaRequestItem *requestItem, BOOL isSuccessed, NSDictionary *userInfo) {
		 NSArray *shareList = userInfo[@"v"][@"data"];
		 if (!shareList)
			 return;

		 [_shareListMgr addSharesWithArray:shareList];

		 if (_isLoading) {
			 [self reloadLoopPlayerData];
			 _isLoading = NO;
		 }
	 } timeoutBlock:^(MiaRequestItem *requestItem) {
		 NSLog(@"getNearbyWithLatitude timeout");
	 }];
}

#pragma mark - swip actions

- (void)spreadFeed {
	NSLog(@"#swipe# up spred");
	// 传播出去不需要切换歌曲，需要记录下传播的状态和上报服务器
	[MiaAPIHelper InfectMusicWithLatitude:[_radioViewDelegate radioViewCurrentCoordinate].latitude
								longitude:[_radioViewDelegate radioViewCurrentCoordinate].longitude
								  address:[_radioViewDelegate radioViewCurrentAddress]
									 spID:[[self currentShareItem] spID]];
}

- (void)skipFeed {
	NSLog(@"#swipe# down");
	// 向上滑动，用右边的卡片替换当前卡片，并用新卡片填充右侧的卡片，而且之前的歌曲需要从列表中删除

	// 停止当前，并标记为已读，检查下历史记录是否超出最大个数
	[[_loopPlayerView getCurrentPlayerView] stopMusic];
	[_loopPlayerView getCurrentPlayerView].shareItem.unread = NO;
	[_shareListMgr checkHistoryItemsMaxCount];

	// 用右边的卡片替代当前卡片内容
	[_loopPlayerView getCurrentPlayerView].shareItem = [_loopPlayerView getRightPlayerView].shareItem;

	// 删除当前卡片并更新右侧的卡片
	if ([_shareListMgr cursorShiftRightWithRemoveCurrent]) {
		ShareItem *newItem = [_shareListMgr getRightItem];
		[_loopPlayerView getRightPlayerView].shareItem = newItem;

		// 播放当前卡片上的歌曲
		[self playCurrentItem:[_loopPlayerView getCurrentPlayerView].shareItem];

		// 检查是否需要获取新的数据
		[self checkIsNeedToGetNewItems];

		[MiaAPIHelper SkipMusicWithLatitude:[_radioViewDelegate radioViewCurrentCoordinate].latitude
								  longitude:[_radioViewDelegate radioViewCurrentCoordinate].longitude
									address:[_radioViewDelegate radioViewCurrentAddress]
									   spID:[[self currentShareItem] spID]];
	} else {
		NSLog(@"skip feed failed.");
		// TODO 这种情况应该从界面上禁止他翻页
	}
}

#pragma mark - LoopPlayerViewDelegate

- (void)notifySwipeLeft {
	NSLog(@"#swipe# left");
	// 向左滑动，右侧的卡片需要补充

	// 停止当前，并标记为已读，检查下历史记录是否超出最大个数
	[[_loopPlayerView getLeftPlayerView] pauseMusic];
	[_loopPlayerView getLeftPlayerView].shareItem.unread = NO;
	// 这一句是多余的，因为shareItem是对象，引用传值，
	// loopPlaerView和shareListMgr的对象是同一个，改一次就可以了
	//[shareListMgr getCurrentItem].unread = NO;
	[_shareListMgr checkHistoryItemsMaxCount];

	// 补充一条右边的卡片
	if ([_shareListMgr cursorShiftRight]) {
		ShareItem *newItem = [_shareListMgr getRightItem];
		[_loopPlayerView getRightPlayerView].shareItem = newItem;

		// 播放当前卡片上的歌曲
		[self playCurrentItem:[_loopPlayerView getCurrentPlayerView].shareItem];

		// 检查是否需要获取新的数据
		[self checkIsNeedToGetNewItems];
	} else {
		NSLog(@"shift cursor to right failed.");
		// 检查是否需要获取新的数据
		[self checkIsNeedToGetNewItems];
		// TODO 这种情况应该从界面上禁止他翻页
	}
}

- (void)notifySwipeRight {
	NSLog(@"#swipe# right");
	// 向右滑动，左侧的卡片需要补充

	// 停止当前，这个方向的歌曲都是已读的，所以不需要再标记为已读
	[[_loopPlayerView getRightPlayerView] pauseMusic];

	// 补充一条左边的卡片
	if ([_shareListMgr cursorShiftLeft]) {
		ShareItem *newItem = [_shareListMgr getLeftItem];
		[_loopPlayerView getLeftPlayerView].shareItem = newItem;

		// 播放当前卡片上的歌曲
		[self playCurrentItem:[_loopPlayerView getCurrentPlayerView].shareItem];

		// 检查是否需要获取新的数据
		[self checkIsNeedToGetNewItems];
	} else {
		NSLog(@"shift cursor to left failed.");
		// TODO 这种情况应该从界面上禁止他翻页
	}
}

#pragma mark - Actions

- (void)favoriteButtonAction:(id)sender {
	if ([[UserSession standard] isLogined]) {
		NSLog(@"favorite to profile page.");

		[MiaAPIHelper favoriteMusicWithShareID:[self currentShareItem].sID isFavorite:![self currentShareItem].favorite];
	} else {
		[_radioViewDelegate radioViewShouldLogin];
	}
}

- (void)bottomViewTouchAction:(id)sender {
	NSLog(@"bottomViewTouchAction");
	[_radioViewDelegate radioViewDidTouchBottom];
}

- (void)reportViewsTimerAction {
	[MiaAPIHelper viewShareWithLatitude:[_radioViewDelegate radioViewCurrentCoordinate].latitude
							  longitude:[_radioViewDelegate radioViewCurrentCoordinate].longitude
								address:[_radioViewDelegate radioViewCurrentAddress]
								   spID:[[self currentShareItem] spID]];
}

@end
