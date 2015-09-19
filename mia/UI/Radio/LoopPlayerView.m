//
//  LoopPlayerView.m
//  mia
//
//  Created by linyehui on 2015/09/09.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "LoopPlayerView.h"

typedef NS_ENUM(NSUInteger, LoopPlayerViewPaging) {
	LoopPlayerViewPagingCurrent	 	= 0,
	LoopPlayerViewPagingLeft	= 1,
	LoopPlayerViewPagingRight		= 2,
};

@implementation LoopPlayerView {
	NSInteger lastPage;
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
	_playerScrollView = [[PXInfiniteScrollView alloc] initWithFrame:self.bounds];
	_playerScrollView.delegate = self;
	//_playerScrollView.backgroundColor = [UIColor redColor];
	[_playerScrollView setTranslatesAutoresizingMaskIntoConstraints:FALSE];
	[_playerScrollView setScrollDirection:PXInfiniteScrollViewDirectionHorizontal];
	[self addSubview:_playerScrollView];

	static const int kPlayerViewNum = 3;
	NSMutableArray *viewArray = [[NSMutableArray alloc] initWithCapacity:kPlayerViewNum];
	for (int i = 0; i < kPlayerViewNum; i++) {
		PlayerView *aView = [[PlayerView alloc] initWithFrame:self.bounds];
		[viewArray addObject:aView];
	}

	[_playerScrollView setPages:viewArray];
	lastPage = [_playerScrollView currentPage];
}

#pragma mark public method

- (PlayerView *)getCurrentPlayerView {
	return (PlayerView *)[_playerScrollView currentPageView];
}

- (PlayerView *)getLeftPlayerView {
	NSInteger prevIndex = ([_playerScrollView currentPage] - 1 + [_playerScrollView pageCount]) % [_playerScrollView pageCount];
	return [[_playerScrollView pages] objectAtIndex:prevIndex];
}

- (PlayerView *)getRightPlayerView {
	NSInteger nextIndex = ([_playerScrollView currentPage] + 1) % [_playerScrollView pageCount];
	return [[_playerScrollView pages] objectAtIndex:nextIndex];
}

- (void)notifyMusicPlayerMgrDidPlay {
	[[self getCurrentPlayerView] notifyMusicPlayerMgrDidPlay];
}
- (void)notifyMusicPlayerMgrDidPause {
	[[self getCurrentPlayerView] notifyMusicPlayerMgrDidPause];
}

#pragma mark UIScrollViewDelegate

// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	NSLog(@"scrollViewWillBeginDragging++++++++++++++++++++++++");
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	NSLog(@"scrollViewDidEndDragging========================%d", (int)[_playerScrollView currentPage]);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollViewSender {
	NSLog(@"scrollViewDidEndDecelerating***************************");
	LoopPlayerViewPaging pagingDirection = [self checkPagingDirection];
	switch (pagingDirection) {
		case LoopPlayerViewPagingCurrent:
			NSLog(@"LoopPlayerViewPagingCurrent");
			break;
		case LoopPlayerViewPagingLeft:
			NSLog(@"LoopPlayerViewPagingLeft");
			[_loopPlayerViewDelegate notifySwipeLeft];
			break;
		case LoopPlayerViewPagingRight:
			NSLog(@"LoopPlayerViewPagingRight");
			[_loopPlayerViewDelegate notifySwipeRight];
			break;
		default:
			NSLog(@"Error PagingDirection!!");
			break;
	}

	lastPage = [_playerScrollView currentPage];
}

// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	NSLog(@"scrollViewDidEndScrollingAnimation------------------------");
}


# pragma mark - 

- (LoopPlayerViewPaging)checkPagingDirection {
	NSLog(@"lastPage:%d, currentPage:%d", (int)lastPage, (int)[_playerScrollView currentPage]);

	if (lastPage == [_playerScrollView currentPage]) {
		return LoopPlayerViewPagingCurrent;
	}

	NSInteger maxIndex = MAX(0, [_playerScrollView pageCount] - 1);
	if (lastPage == 0) {
		// 第一个，需要判断向右翻页后翻到了最后一页的情况
		if (maxIndex == [_playerScrollView currentPage]) {
			return LoopPlayerViewPagingRight;
		} else {
			return LoopPlayerViewPagingLeft;
		}
	} else if (lastPage == maxIndex) {
		// 最后一个，需要判断向左滑动，到了第一页的情况
		if (0 == [_playerScrollView currentPage]) {
			return LoopPlayerViewPagingLeft;
		} else {
			return LoopPlayerViewPagingRight;
		}
	} else {
		// 中间页面，直接判断大于小于即可
		if (lastPage > [_playerScrollView currentPage]) {
			return LoopPlayerViewPagingRight;
		} else {
			return LoopPlayerViewPagingLeft;
		}
	}
}

@end
