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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HXMusicPlayerMgrDidPlayNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HXMusicPlayerMgrDidPauseNotification object:nil];

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
    if ([[MusicMgr standard] isPlayingWithUrl:_currentItem.music.murl]) {
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
    
    _songNameLabel.text = music.name ?: @"";
    _songerNameLabel.text = music.singerName ?: @"";
    _starButton.selected = item.favorite;
    _sharerNickNameLabel.text = item.sNick;
    [_frontCoverView sd_setImageWithURL:[NSURL URLWithString:music.purl]];
    [self displayShareContentLabelWithContent:item.sNote locationInfo:[NSString stringWithFormat:@"♫%@", item.sAddress]];
    
    if (_delegate && [_delegate respondsToSelector:@selector(radioViewDidLoad:item:)]) {
        [_delegate radioViewDidLoad:self item:_currentItem];
    }
}

#pragma mark - Private Methods
static NSInteger MaxLine = 3;
static NSString *HanWorld = @"肖";
- (void)displayShareContentLabelWithContent:(NSString *)content locationInfo:(NSString *)locationInfo {
    NSString *text = [NSString stringWithFormat:@"%@%@", (content.length ? [NSString stringWithFormat:@"“%@”  ", content] : @""), (locationInfo ?: @"")];
    
    CGFloat labelWidth = _shrareContentLabel.frame.size.width;
    CGSize maxSize = CGSizeMake(labelWidth, MAXFLOAT);
    UIFont *labelFont = _shrareContentLabel.font;
    CGFloat textHeight = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:labelFont} context:nil].size.height;
    CGFloat lineHeight = [@" " boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:labelFont} context:nil].size.height;
    CGFloat threeLineHeightThreshold = lineHeight*3;
    if (textHeight > lineHeight) {
        _shrareContentLabel.textAlignment = NSTextAlignmentLeft;
        
        if (textHeight > threeLineHeightThreshold) {
            CGFloat maxWidth = labelWidth*MaxLine;
            CGSize locationMaxSize = CGSizeMake(MAXFLOAT, lineHeight);
            NSString *coutText = [NSString stringWithFormat:@"...”  %@", locationInfo];
            CGFloat worldWith = [HanWorld boundingRectWithSize:locationMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:labelFont} context:nil].size.width;
            CGFloat locationInfoWidth = [coutText boundingRectWithSize:locationMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_shrareContentLabel.font} context:nil].size.width;
            CGFloat commentSurplusWidth = maxWidth - locationInfoWidth;
            NSInteger commentWorldCount = (commentSurplusWidth/worldWith);
            text = [NSString stringWithFormat:@"%@%@", [text substringWithRange:(NSRange){0, commentWorldCount}], coutText];
        }
    } else {
        _shrareContentLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    
    [_shrareContentLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange boldRange = [[mutableAttributedString string] rangeOfString:locationInfo options:NSCaseInsensitiveSearch];
        [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)[UIColor lightGrayColor].CGColor range:boldRange];
        return mutableAttributedString;
    }];
}

- (void)displayPlayProgress {
    _progressView.progress = [[[MusicMgr standard] listPlayer] playPosition];
}

#pragma mark - TTTAttributedLabelDelegate Methods
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if (_delegate && [_delegate respondsToSelector:@selector(radioViewSharerNameTaped:)]) {
        [_delegate radioViewSharerNameTaped:self];
    }
}

@end
