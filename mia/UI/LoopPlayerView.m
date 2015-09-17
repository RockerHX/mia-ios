//
//  LoopPlayerView.m
//  mia
//
//  Created by linyehui on 2015/09/09.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "LoopPlayerView.h"
#import "PXInfiniteScrollView.h"
#import "PlayerView.h"

@implementation LoopPlayerView {
	PXInfiniteScrollView *playerScrollView;
	//PlayerView *playerView;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self){
		self.userInteractionEnabled = YES;
		//self.backgroundColor = [UIColor redColor];
		[self initPlayerView];
	}

	return self;
}

- (void)initPlayerView {
	playerScrollView = [[PXInfiniteScrollView alloc] initWithFrame:self.bounds];
	//playerScrollView.backgroundColor = [UIColor redColor];
	[playerScrollView setTranslatesAutoresizingMaskIntoConstraints:FALSE];
	[playerScrollView setScrollDirection:PXInfiniteScrollViewDirectionHorizontal];
	[self addSubview:playerScrollView];

	static const int kPlayerViewNum = 3;
	NSMutableArray *viewArray = [[NSMutableArray alloc] initWithCapacity:kPlayerViewNum];
	for (int i = 0; i < kPlayerViewNum; i++) {
		PlayerView *aView = [[PlayerView alloc] initWithFrame:self.bounds];
		[viewArray addObject:aView];
	}

	[playerScrollView setPages:viewArray];
}

#pragma mark public method

- (PlayerView *)getCurrentPlayerView {
	return (PlayerView *)[playerScrollView currentPageView];
}

- (PlayerView *)getPrevPlayerView {
	NSInteger prevIndex = ([playerScrollView currentPage] - 1 + [playerScrollView pageCount]) % [playerScrollView pageCount];
	return [[playerScrollView pages] objectAtIndex:prevIndex];
}

- (PlayerView *)getNextPlayerView {
	NSInteger nextIndex = ([playerScrollView currentPage] + 1) % [playerScrollView pageCount];
	return [[playerScrollView pages] objectAtIndex:nextIndex];
}

- (void)setShareItem:(ShareItem *)item {
	[[self getCurrentPlayerView] setShareItem:item];
}

- (void)notifyMusicPlayerMgrDidPlay {
	[[self getCurrentPlayerView] notifyMusicPlayerMgrDidPlay];
}
- (void)notifyMusicPlayerMgrDidPause {
	[[self getCurrentPlayerView] notifyMusicPlayerMgrDidPause];
}

@end
