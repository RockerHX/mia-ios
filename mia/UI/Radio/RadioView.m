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

static const CGFloat kPlayerMarginTop			= 90;
static const CGFloat kPlayerHeight				= 300;

static const CGFloat kFavoriteMarginBottom = 80;
static const CGFloat kFavoriteWidth = 25;
static const CGFloat kFavoriteHeight = 25;

@interface RadioView () <LoopPlayerViewDelegate>

@end

@implementation RadioView {
	ShareListMgr *shareListMgr;
	
	MIAButton *pingButton;
	MIAButton *loginButton;
	MIAButton *reconnectButton;

	LoopPlayerView *loopPlayerView;

	MIAButton *favoriteButton;
	MIALabel *commentLabel;
	MIALabel *viewsLabel;
	MIALabel *locationLabel;

	NSTimer *progressTimer;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self){
		self.userInteractionEnabled = YES;
//		self.backgroundColor = [UIColor redColor];

		[self initShareList];
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
	loopPlayerView = [[LoopPlayerView alloc] initWithFrame:CGRectMake(0, kPlayerMarginTop, self.frame.size.width, kPlayerHeight)];
	loopPlayerView.loopPlayerViewDelegate = self;
	[self addSubview:loopPlayerView];

	favoriteButton = [[MIAButton alloc] initWithFrame:CGRectMake(self.bounds.size.width / 2 - kFavoriteWidth / 2,
																 self.bounds.size.height - kFavoriteMarginBottom - kFavoriteHeight,
																 kFavoriteWidth,
																 kFavoriteHeight)
										  titleString:nil
										   titleColor:nil
												 font:nil
											  logoImg:nil
									  backgroundImage:nil];
	[favoriteButton setImage:[UIImage imageNamed:@"favorite_normal"] forState:UIControlStateNormal];
	[favoriteButton addTarget:self action:@selector(favoriteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:favoriteButton];

	[self initBottomView];
/*
	CGRect pingButtonFrame = CGRectMake(60,
										50.0f,
										200,
										50);

	pingButton = [[MIAButton alloc] initWithFrame:pingButtonFrame
									  titleString:@"Ping" titleColor:[UIColor whiteColor]
											 font:UIFontFromSize(15)
										  logoImg:nil
								  backgroundImage:[UIImage createImageWithColor:DADU_DEFAULT_COLOR]];

	pingButton.layer.masksToBounds = YES;
	pingButton.layer.cornerRadius = 5.0f;
	[pingButton addTarget:self action:@selector(onClickPingButton:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:pingButton];

	CGRect loginButtonFrame = CGRectMake(60,
										130.0f,
										200,
										50);

	loginButton = [[MIAButton alloc] initWithFrame:loginButtonFrame
									  titleString:@"Login" titleColor:[UIColor whiteColor]
											 font:UIFontFromSize(15)
										  logoImg:nil
								  backgroundImage:[UIImage createImageWithColor:DADU_DEFAULT_COLOR]];

	loginButton.layer.masksToBounds = YES;
	loginButton.layer.cornerRadius = 5.0f;
	[loginButton addTarget:self action:@selector(onClickLoginButton:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:loginButton];
	
	CGRect reconnectButtonFrame = CGRectMake(60,
										 210.0f,
										 200,
										 50);

	reconnectButton = [[MIAButton alloc] initWithFrame:reconnectButtonFrame
									   titleString:@"Reconnect" titleColor:[UIColor whiteColor]
											  font:UIFontFromSize(15)
										   logoImg:nil
								   backgroundImage:[UIImage createImageWithColor:DADU_DEFAULT_COLOR]];

	reconnectButton.layer.masksToBounds = YES;
	reconnectButton.layer.cornerRadius = 5.0f;
	[reconnectButton addTarget:self action:@selector(onClickReconnectButton:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:reconnectButton];

*/
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

	commentLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kCommentImageMarginLeft + kBottomButtonWidth + kCommentLabelMarginLeft,
															  bottomView.bounds.size.height - kBottomLabelMarginBottom - kBottomLabelHeight,
															  kCommentLabelWidth,
															  kBottomLabelHeight)
											  text:@""
											  font:UIFontFromSize(8.0f)
										 textColor:[UIColor grayColor]
									 textAlignment:NSTextAlignmentLeft
									   numberLines:1];
	//commentLabel.backgroundColor = [UIColor redColor];
	[bottomView addSubview:commentLabel];

	UIImageView *viewsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kViewsImageMarginLeft,
																				bottomView.bounds.size.height - kBottomButtonMarginBottom - kBottomButtonHeight,
																				kBottomButtonWidth,
																				kBottomButtonHeight)];
	[viewsImageView setImage:[UIImage imageNamed:@"views"]];
	[bottomView addSubview:viewsImageView];

	viewsLabel = [[MIALabel alloc] initWithFrame:CGRectMake(kViewsImageMarginLeft + kBottomButtonWidth + kViewsLabelMarginLeft,
															bottomView.bounds.size.height - kBottomLabelMarginBottom - kBottomLabelHeight,
															kViewsLabelWidth,
															kBottomLabelHeight)
											text:@""
											font:UIFontFromSize(8.0f)
									   textColor:[UIColor grayColor]
								   textAlignment:NSTextAlignmentLeft
									 numberLines:1];
	//viewsLabel.backgroundColor = [UIColor redColor];
	[bottomView addSubview:viewsLabel];

	UIImageView *locationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(bottomView.bounds.size.width - kLocationLabelMarginRight - kLocationLabelWidth - kLocationImageMarginRight - kBottomButtonWidth,
																				   bottomView.bounds.size.height - kBottomButtonMarginBottom - kBottomButtonHeight,
																				   kBottomButtonWidth,
																				   kBottomButtonHeight)];
	[locationImageView setImage:[UIImage imageNamed:@"location"]];
	[bottomView addSubview:locationImageView];

	locationLabel = [[MIALabel alloc] initWithFrame:CGRectMake(bottomView.bounds.size.width - kLocationLabelMarginRight - kLocationLabelWidth,
															   bottomView.bounds.size.height - kBottomLabelMarginBottom - kBottomLabelHeight,
															   kLocationLabelWidth,
															   kBottomLabelHeight)
											   text:@""
											   font:UIFontFromSize(8.0f)
									   textColor:[UIColor grayColor]
								   textAlignment:NSTextAlignmentLeft
									 numberLines:1];
	//locationLabel.backgroundColor = [UIColor redColor];
	[bottomView addSubview:locationLabel];
}

- (void)initShareList {
	shareListMgr = [ShareListMgr initFromArchive];
	// TODO 获取当前需要的三个Item，如果能获取到就不需要Loading状态了
	_isLoading = YES;
}

- (void)reloadLoopPlayerData {
	ShareItem *currentItem = [shareListMgr getCurrentItem];
	ShareItem *leftItem = [shareListMgr getLeftItem];
	ShareItem *rightItem = [shareListMgr getRightItem];

	[loopPlayerView getCurrentPlayerView].shareItem = currentItem;
	[[loopPlayerView getCurrentPlayerView] playMusic];
	[self updateUIInfo:currentItem];

	[loopPlayerView getLeftPlayerView].shareItem = leftItem;
	[loopPlayerView getRightPlayerView].shareItem = rightItem;
}

- (void)checkIsNeedToGetNewItems {
	if ([shareListMgr isNeedGetNearbyItems]) {
		// TODO linyehui
		[MiaAPIHelper getNearbyWithLatitude:-22.1 longitude:33.3 start:1 item:3];
	}
}

- (void)updateUIInfo:(ShareItem *)item {
	_currentShareItem = item;
	[commentLabel setText: 0 == [item cComm] ? @"" : NSStringFromInt([item cComm])];
	[viewsLabel setText: 0 == [item cView] ? @"" : NSStringFromInt([item cView])];
	[locationLabel setText:[item sAddress]];
}

#pragma mark - Notification

-(void)notificationWebSocketDidReceiveMessage:(NSNotification *)notification {
	NSString *command = [notification userInfo][MiaAPIKey_ServerCommand];
	id ret = [notification userInfo][MiaAPIKey_Values][MiaAPIKey_Return];

	NSLog(@"command:%@, ret:%d", command, [ret intValue]);

	if ([command isEqualToString:MiaAPICommand_Music_GetNearby]) {
		[self handleGetNearbyFeedsWitRet:[ret intValue] userInfo:[notification userInfo]];
	} else if ([command isEqualToString:MiaAPICommand_User_PostInfectm]) {
		[self handleInfectMusicWitRet:[ret intValue] userInfo:[notification userInfo]];
	} else if ([command isEqualToString:MiaAPICommand_User_PostSkipm]) {
		[self handleSkipMusicWitRet:[ret intValue] userInfo:[notification userInfo]];
	}
}

- (void)notificationMusicPlayerMgrDidPlay:(NSNotification *)notification {
	[loopPlayerView notifyMusicPlayerMgrDidPlay];
}

- (void)notificationMusicPlayerMgrDidPause:(NSNotification *)notification {
	[loopPlayerView notifyMusicPlayerMgrDidPause];
}

- (void)notificationMusicPlayerMgrCompletion:(NSNotification *)notification {
	NSLog(@"#swipe# completion");
	// 播放完成自动下一首，用右边的卡片替换当前卡片，并用新卡片填充右侧的卡片

	// 停止当前，并标记为已读，检查下历史记录是否超出最大个数
	[[loopPlayerView getCurrentPlayerView] pauseMusic];
	[loopPlayerView getCurrentPlayerView].shareItem.unread = NO;
	[shareListMgr checkHistoryItemsMaxCount];

	// 用当前的卡片内容替代左边的卡片内容
	[loopPlayerView getLeftPlayerView].shareItem = [loopPlayerView getCurrentPlayerView].shareItem;
	// 用右边的卡片内容替代当前的卡片内容
	[loopPlayerView getCurrentPlayerView].shareItem = [loopPlayerView getRightPlayerView].shareItem;
	[self updateUIInfo:[loopPlayerView getCurrentPlayerView].shareItem];
	// 更新右边的卡片内容
	if ([shareListMgr cursorShiftRight]) {
		ShareItem *newItem = [shareListMgr getRightItem];
		[loopPlayerView getRightPlayerView].shareItem = newItem;

		// 播放当前卡片上的歌曲
		[[loopPlayerView getCurrentPlayerView] playMusic];

		// 检查是否需要获取新的数据
		[self checkIsNeedToGetNewItems];
	} else {
		NSLog(@"play completion failed.");
		// TODO 这种情况应该从界面上禁止他翻页
	}
}

#pragma mark - received message from websocket

- (void)handleGetNearbyFeedsWitRet:(int)ret userInfo:(NSDictionary *) userInfo {
	NSArray *shareList = userInfo[@"v"][@"data"];
	if (!shareList)
		return;

	[shareListMgr addSharesWithArray:shareList];

	if (_isLoading) {
		[self reloadLoopPlayerData];
		_isLoading = NO;
	}
}

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

#pragma mark - swip actions

- (void)spreadFeed {
	NSLog(@"#swipe# up spred");
	// 传播出去不需要切换歌曲，需要记录下传播的状态和上报服务器
	// TODO 使用获取到的经纬度来上报
	[MiaAPIHelper InfectMusicWithLatitude:-22.3 longitude:33.6 address:@"深圳,南山区" spID:[_currentShareItem spID]];
}

- (void)skipFeed {
	NSLog(@"#swipe# down");
	// 向上滑动，用右边的卡片替换当前卡片，并用新卡片填充右侧的卡片，而且之前的歌曲需要从列表中删除

	// 停止当前，并标记为已读，检查下历史记录是否超出最大个数
	[[loopPlayerView getCurrentPlayerView] stopMusic];
	[loopPlayerView getCurrentPlayerView].shareItem.unread = NO;
	[shareListMgr checkHistoryItemsMaxCount];

	// 用右边的卡片替代当前卡片内容
	[loopPlayerView getCurrentPlayerView].shareItem = [loopPlayerView getRightPlayerView].shareItem;
	[self updateUIInfo:[loopPlayerView getCurrentPlayerView].shareItem];

	// 删除当前卡片并更新右侧的卡片
	if ([shareListMgr cursorShiftRightWithRemoveCurrent]) {
		ShareItem *newItem = [shareListMgr getRightItem];
		[loopPlayerView getRightPlayerView].shareItem = newItem;

		// 播放当前卡片上的歌曲
		[[loopPlayerView getCurrentPlayerView] playMusic];

		// 检查是否需要获取新的数据
		[self checkIsNeedToGetNewItems];

		// TODO 使用获取到的经纬度来上报
		[MiaAPIHelper SkipMusicWithLatitude:-22.3 longitude:33.6 address:@"深圳,南山区" spID:[_currentShareItem spID]];
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
	[[loopPlayerView getLeftPlayerView] pauseMusic];
	[loopPlayerView getLeftPlayerView].shareItem.unread = NO;
	// 这一句是多余的，因为shareItem是对象，引用传值，
	// loopPlaerView和shareListMgr的对象是同一个，改一次就可以了
	//[shareListMgr getCurrentItem].unread = NO;
	[shareListMgr checkHistoryItemsMaxCount];

	// 补充一条右边的卡片
	if ([shareListMgr cursorShiftRight]) {
		ShareItem *newItem = [shareListMgr getRightItem];
		[loopPlayerView getRightPlayerView].shareItem = newItem;

		// 播放当前卡片上的歌曲
		[[loopPlayerView getCurrentPlayerView] playMusic];

		// 检查是否需要获取新的数据
		[self checkIsNeedToGetNewItems];
	} else {
		NSLog(@"shift cursor to right failed.");
		// TODO 这种情况应该从界面上禁止他翻页
	}
}

- (void)notifySwipeRight {
	NSLog(@"#swipe# right");
	// 向右滑动，左侧的卡片需要补充

	// 停止当前，这个方向的歌曲都是已读的，所以不需要再标记为已读
	[[loopPlayerView getRightPlayerView] pauseMusic];

	// 补充一条左边的卡片
	if ([shareListMgr cursorShiftLeft]) {
		ShareItem *newItem = [shareListMgr getLeftItem];
		[loopPlayerView getLeftPlayerView].shareItem = newItem;

		// 播放当前卡片上的歌曲
		[[loopPlayerView getCurrentPlayerView] playMusic];

		// 检查是否需要获取新的数据
		[self checkIsNeedToGetNewItems];
	} else {
		NSLog(@"shift cursor to left failed.");
		// TODO 这种情况应该从界面上禁止他翻页
	}
}

#pragma mark - Actions

- (void)favoriteButtonAction:(id)sender {
	NSLog(@"favoriteButtonAction");
}

- (void)bottomViewTouchAction:(id)sender {
	NSLog(@"bottomViewTouchAction");
	[_radioViewDelegate radioViewDidTouchBottom];
}

@end
