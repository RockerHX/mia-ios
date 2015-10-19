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

@interface HXRadioView () <TTTAttributedLabelDelegate> {
	ShareItem *_currentItem;
}

@end

@implementation HXRadioView

#pragma mark - Class Methods
+ (instancetype)initWithFrame:(CGRect)frame delegate:(id<HXRadioViewDelegate>)delegate {
    HXRadioView *radioView = [[[NSBundle mainBundle] loadNibNamed:@"HXRadioView" owner:self options:nil] firstObject];
    radioView.frame = frame;
    radioView.delegate = delegate;
    
    return radioView;
}

#pragma Init Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initConfig];
    [self viewConfig];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MusicPlayerMgrNotificationDidPlay object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MusicPlayerMgrNotificationDidPause object:nil];

}

#pragma mark - Config Methods
- (void)initConfig {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationMusicPlayerMgrDidPlay) name:MusicPlayerMgrNotificationDidPlay object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationMusicPlayerMgrDidPause) name:MusicPlayerMgrNotificationDidPause object:nil];
}

- (void)viewConfig {
    [self configLabel];
}

- (void)configLabel {
    _shrareContentLabel.delegate = self;
    _shrareContentLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
}

#pragma mark - Notification
- (void)notificationMusicPlayerMgrDidPlay {
    _playButton.selected = NO;
}

- (void)notificationMusicPlayerMgrDidPause {
    _playButton.selected = YES;
}

#pragma mark - Event Response
- (IBAction)tapGesture {
    [self playButtonPressed:_playButton];
}

- (IBAction)playButtonPressed:(UIButton *)button {
    if (button.selected) {
        if (_delegate && [_delegate respondsToSelector:@selector(radioViewShouldPlay:)]) {
            [_delegate radioViewShouldPlay:self];
        }
    } else {
        if (_delegate && [_delegate respondsToSelector:@selector(radioViewShouldPause:)]) {
            [_delegate radioViewShouldPause:self];
        }
    }
    button.selected = !button.selected;
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
			 } else {
				 NSLog(@"favorite music failed");
			 }
		 } timeoutBlock:^(MiaRequestItem *requestItem) {
			 NSLog(@"favorite music timeout");
		 }];
	} else {
		if (_delegate && [_delegate respondsToSelector:@selector(radioViewStarTapedNeedLogin:)]) {
			[_delegate radioViewStarTapedNeedLogin:self];
		}
	}
}

#pragma mark - Public Methods
- (void)displayWithItem:(ShareItem *)item {
    _currentItem = item;
    _playButton.selected = NO;
    MusicItem *music = item.music;
    
    [_frontCoverView sd_setImageWithURL:[NSURL URLWithString:music.purl]];
    _songNameLabel.text = [NSString stringWithFormat:@"%@ %@", (music.name ?: @""), (music.singerName ?: @"")];
    _starButton.selected = item.favorite;
    _shrareContentLabel.text = [NSString stringWithFormat:@"%@:%@", (item.sNick ?: @""), (item.sNote ?: @"")];
    _locationLabel.text = [item sAddress] ?: @"";
    
    [self displayShareContentLabelWithSharerName:item.sNick];
    
    if (_delegate && [_delegate respondsToSelector:@selector(radioViewDidLoad:item:)]) {
        [_delegate radioViewDidLoad:self item:_currentItem];
    }
}

#pragma mark - Private Methods
- (void)displayShareContentLabelWithSharerName:(NSString *)sharerName {
    NSRange range = [_shrareContentLabel.text rangeOfString:(sharerName ?: @"")];
    [_shrareContentLabel addLinkToURL:[NSURL URLWithString:@""] withRange:range];
}

#pragma mark - TTTAttributedLabelDelegate Methods
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if (_delegate && [_delegate respondsToSelector:@selector(radioViewSharerNameTaped:)]) {
        [_delegate radioViewSharerNameTaped:self];
    }
}

@end
