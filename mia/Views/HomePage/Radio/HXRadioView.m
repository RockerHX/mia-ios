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
#import "MusicPlayerMgr.h"
#import "HXAppConstants.h"
#import "HXAlertBanner.h"

@interface HXRadioView () <TTTAttributedLabelDelegate> {
	ShareItem *_currentItem;
    NSTimer *_timer;
}

@end

@implementation HXRadioView

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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MusicPlayerMgrNotificationDidPlay object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MusicPlayerMgrNotificationDidPause object:nil];

}

#pragma mark - Config Methods
- (void)initConfig {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationDidPlay) name:HXMusicPlayerMgrDidPlayNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationDidPause) name:HXMusicPlayerMgrDidPauseNotification object:nil];
    
}

- (void)viewConfig {
    [self configLabel];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(displayPlayProgress) userInfo:nil repeats:YES];
}

- (void)configLabel {
    _progressView.progress = 0.0f;
    _shrareContentLabel.delegate = self;
    _shrareContentLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
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

- (IBAction)sharerNickNameTaped {
    if (_delegate && [_delegate respondsToSelector:@selector(radioViewSharerNameTaped:)]) {
        [_delegate radioViewSharerNameTaped:self];
    }
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
	if ([[UserSession standard] isLogined]) {
		[MiaAPIHelper favoriteMusicWithShareID:_currentItem.sID
									isFavorite:!_currentItem.favorite
								 completeBlock:
		 ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
			 if (success) {
				 id act = userInfo[MiaAPIKey_Values][@"act"];
				 id sID = userInfo[MiaAPIKey_Values][@"id"];
				 if ([_currentItem.sID integerValue] == [sID intValue]) {
					 _currentItem.favorite = [act intValue];
					 button.selected = !button.selected;
				 }
				 [HXAlertBanner showWithMessage:@"收藏成功" tap:nil];
			 } else {
				 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
				 [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"收藏失败:%@", error] tap:nil];
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
    if ([[MusicPlayerMgr standard] isPlayingWithUrl:_currentItem.music.murl]) {
        _playButton.selected = NO;
    } else {
        _playButton.selected = YES;
    }
}

#pragma mark - Public Methods
- (void)displayWithItem:(ShareItem *)item {
    _progressView.progress = 0.0f;
    _currentItem = item;
    _playButton.selected = NO;
    MusicItem *music = item.music;
    
    [_frontCoverView sd_setImageWithURL:[NSURL URLWithString:music.purl]];
    _songNameLabel.text = music.name ?: @"";
    _songerNameLabel.text = music.singerName ?: @"";
    _starButton.selected = item.favorite;
    _sharerNickNameLabel.text = item.sNick;
    _shrareContentLabel.text = [NSString stringWithFormat:@"%@♫%@", (item.sNote.length ? [item.sNote stringByAppendingString:@"  "]: @""), ([item sAddress] ?: @"")];
    
//    [self displayShareContentLabelWithSharerName:item.sNick];
    
    if (_delegate && [_delegate respondsToSelector:@selector(radioViewDidLoad:item:)]) {
        [_delegate radioViewDidLoad:self item:_currentItem];
    }
}

#pragma mark - Private Methods
- (void)displayShareContentLabelWithSharerName:(NSString *)sharerName {
//    NSRange range = [_shrareContentLabel.text rangeOfString:(sharerName ?: @"")];
//    [_shrareContentLabel addLinkToURL:[NSURL URLWithString:@""] withRange:range];
}

- (void)displayPlayProgress {
    _progressView.progress = [[SingleSongPlayer standard] getPlayPosition];
}

#pragma mark - TTTAttributedLabelDelegate Methods
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if (_delegate && [_delegate respondsToSelector:@selector(radioViewSharerNameTaped:)]) {
        [_delegate radioViewSharerNameTaped:self];
    }
}

@end
