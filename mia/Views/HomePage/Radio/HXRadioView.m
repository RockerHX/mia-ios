//
//  HXRadioView.m
//  mia
//
//  Created by miaios on 15/10/17.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXRadioView.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "ShareItem.h"
#import "UIImageView+WebCache.h"
#import "UserSession.h"
#import "MiaAPIHelper.h"
#import "HXAppConstants.h"
#import "HXAlertBanner.h"
#import "MusicMgr.h"
#import "SongListPlayer.h"
#import "FavoriteMgr.h"
#import "HXVersion.h"
#import "HXRadioShareInfoView.h"

@implementation HXRadioView {
    ShareItem *_currentItem;
    NSTimer *_timer;
}

#pragma mark - Class Methods
+ (instancetype)initWithFrame:(CGRect)frame delegate:(id<HXRadioViewDelegate>)delegate {
    HXRadioView *radioView = nil;
    @try {
        radioView = [[[NSBundle mainBundle] loadNibNamed:@"HXRadioView" owner:self options:nil] firstObject];
    }
    @catch (NSException *exception) {
        NSLog(@"HXRadioView Load From Nib Error:%@", exception.reason);
    }
    @finally {
        radioView.frame = frame;
        radioView.delegate = delegate;
        return radioView;
    }
}

#pragma Init Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initConfig];
    [self viewConfig];
}

- (void)dealloc {
    [_timer invalidate];
    
    [_currentItem removeObserver:self forKeyPath:@"favorite"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HXMusicPlayerMgrDidPlayNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HXMusicPlayerMgrDidPauseNotification object:nil];

}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"favorite"]) {
        NSNumber *favorite = change[NSKeyValueChangeNewKey];
        [_starButton setImage:[UIImage imageNamed:([favorite boolValue] ? @"HP-StarIcon" : @"HP-UnStarIcon")] forState:UIControlStateNormal];
    }
}

#pragma mark - Config Methods
- (void)initConfig {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationDidPlay) name:HXMusicPlayerMgrDidPlayNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationDidPause) name:HXMusicPlayerMgrDidPauseNotification object:nil];
    
}

- (void)viewConfig {
    [self configLabel];
    [self configFrontCover];
    [self hanleUnderiPhone6Size];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(displayPlayProgress) userInfo:nil repeats:YES];
}

- (void)configLabel {
    _progressView.progress = 0.0f;
}

- (void)configFrontCover {
    _frontCoverView.layer.borderColor = UIColorFromHex(@"d7dede", 1.0f).CGColor;
    _frontCoverView.layer.borderWidth = 0.5f;
}

- (void)hanleUnderiPhone6Size {
    if ([HXVersion isIPhone5SPrior]) {
        _coverWidthConstraint.constant = 200.0f;
        [self layoutIfNeeded];
    }
}

#pragma mark - Notification
- (void)notificationDidPlay {
    _playButton.selected = NO;
}

- (void)notificationDidPause {
    _playButton.selected = YES;
}

#pragma mark - Event Response
- (IBAction)coverTaped {
    [self playButtonPressed:_playButton];
}

- (IBAction)playButtonPressed:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        if (_delegate && [_delegate respondsToSelector:@selector(radioViewShouldPause:)]) {
            [_delegate radioViewShouldPause:self];
        }
    } else {
        if (_delegate && [_delegate respondsToSelector:@selector(radioViewShouldPlay:)]) {
            [_delegate radioViewShouldPlay:self];
        }
    }
}

- (IBAction)starButtonPressed:(UIButton *)button {
    __weak __typeof__(self)weakSelf = self;
	if ([[UserSession standard] isLogined]) {
		[MiaAPIHelper favoriteMusicWithShareID:_currentItem.sID
									isFavorite:!_currentItem.favorite
								 completeBlock:
		 ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
             __strong __typeof__(self)strongSelf = weakSelf;
			 if (success) {
				 id act = userInfo[MiaAPIKey_Values][@"act"];
				 id sID = userInfo[MiaAPIKey_Values][@"id"];
                 BOOL favorite = [act intValue];
				 if ([strongSelf->_currentItem.sID integerValue] == [sID intValue]) {
					 strongSelf->_currentItem.favorite = favorite;
				 }
                 
                 [button setImage:[UIImage imageNamed:(favorite ? @"HP-StarIcon" : @"HP-UnStarIcon")] forState:UIControlStateNormal];
                 [HXAlertBanner showWithMessage:(favorite ? @"收藏成功" : @"取消收藏成功") tap:nil];

				 // 收藏操作成功后同步下收藏列表并检查下载
				 [[FavoriteMgr standard] syncFavoriteList];
			 } else {
				 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
				 [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
			 }
		 } timeoutBlock:^(MiaRequestItem *requestItem) {
			 [HXAlertBanner showWithMessage:@"收藏失败，网络请求超时" tap:nil];
		 }];
	} else {
		if (_delegate && [_delegate respondsToSelector:@selector(radioViewStarTapedNeedLogin:)]) {
			[_delegate radioViewStarTapedNeedLogin:self];
		}
	}
}

- (void)reloadPlayStatus {
    if ([[MusicMgr standard] isPlayingWithUrl:_currentItem.music.murl]) {
        _playButton.selected = NO;
    } else {
        _playButton.selected = YES;
    }
}

#pragma mark - Public Methods
- (void)displayWithItem:(ShareItem *)item {
    [self hanleItem:item];
    
    _progressView.progress = 0.0f;
    _playButton.selected = NO;
    MusicItem *music = item.music;
    
    _songNameLabel.text = music.name ?: @"";
    _songerNameLabel.text = music.singerName ?: @"";
    _starButton.selected = item.favorite;
    [_frontCoverView sd_setImageWithURL:[NSURL URLWithString:music.purl]];
    [_shareInfoView displayWithItem:item];
    
    if (_delegate && [_delegate respondsToSelector:@selector(radioViewDidLoad:)]) {
        [_delegate radioViewDidLoad:self];
    }
}

#pragma mark - Private Methods
- (void)hanleItem:(ShareItem *)item {
    [_currentItem removeObserver:self forKeyPath:@"favorite"];
    _currentItem = item;
    [_currentItem addObserver:self forKeyPath:@"favorite" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)displayPlayProgress {
    _progressView.progress = [[[MusicMgr standard] currentPlayer] playPosition];
}

@end
