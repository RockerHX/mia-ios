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
	PlayerView *playerView;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self){
		self.userInteractionEnabled = YES;
		//self.backgroundColor = [UIColor redColor];

		playerView = [[PlayerView alloc] initWithFrame:self.bounds];
		[self addSubview:playerView];
	}

	return self;
}

- (void)setShareItem:(ShareItem *)item {
	[playerView setShareItem:item];
}

- (void)notifyMusicPlayerMgrDidPlay {
	[playerView notifyMusicPlayerMgrDidPlay];
}
- (void)notifyMusicPlayerMgrDidPause {
	[playerView notifyMusicPlayerMgrDidPause];
}

@end
