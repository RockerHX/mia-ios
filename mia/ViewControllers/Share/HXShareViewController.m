//
//  HXShareViewController.m
//  mia
//
//  Created by miaios on 15/10/28.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXShareViewController.h"
#import "SearchViewController.h"
#import "SearchResultItem.h"
#import "MusicItem.h"
#import "MiaAPIHelper.h"
#import "UIImageView+WebCache.h"
#import "UserSession.h"
#import "HXTextView.h"
#import "MBProgressHUDHelp.h"
#import "LocationMgr.h"
#import "HXAlertBanner.h"
#import "MusicMgr.h"
#import "NSObject+BlockSupport.h"
#import "UIConstants.h"
#import "ShareItem.h"
#import "FavoriteItem.h"

@interface HXShareViewController () <SearchViewControllerDelegate, HXTextViewDelegate>
@end

@implementation HXShareViewController {
    BOOL 					_closeLocation;
    NSString 				*_address;
    CLLocationCoordinate2D	_coordinate;
    
    MusicItem 				*_musicItem;
    SearchResultItem 		*_dataItem;
	SearchViewController 	*_searchViewController;
}

#pragma mark - View Controller Life Cycle
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopMusic];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
    [self startUpdatingLocation];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MusicMgrNotificationPlayerEvent object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

+ (HXStoryBoardName)storyBoardName {
    return HXStoryBoardNameShare;
}

#pragma mark - Config Methods
- (void)loadConfigure {
    _scrollView.scrollsToTop = YES;
    _commentTextView.scrollsToTop = NO;
    
    _musicItem = [[MusicItem alloc] init];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationPlayerEvent:) name:MusicMgrNotificationPlayerEvent object:nil];
    //添加键盘监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewConfigure {
    _shareButton.enabled = NO;
    _nickNameLabel.text = [[UserSession standard] nick];
}

#pragma mark - Event Response
- (IBAction)sendButtonPressed {
    NSString *comment = _commentTextView.text;
    if ([comment length] <= 0) {
        comment = @"这首歌不错，记得帮我妙推一下哦";
    }
    
    MBProgressHUD *aMBProgressHUD = [MBProgressHUDHelp showLoadingWithText:@"正在提交分享"];
    [MiaAPIHelper postShareWithLatitude:(_closeLocation ? 0 : _coordinate.latitude)
                              longitude:(_closeLocation ? 0 : _coordinate.longitude)
                                address:(_closeLocation ? @"" : _address)
                                 songID:_dataItem.songID
                                   note:comment
                          completeBlock:
     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
         if (success) {
             [HXAlertBanner showWithMessage:@"分享成功" tap:nil];
             [self.navigationController popViewControllerAnimated:YES];
			 if (_delegate && [_delegate respondsToSelector:@selector(shareViewControllerDidShareMusic)]) {
				 [_delegate shareViewControllerDidShareMusic];
			 }
         } else {
             id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
             [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
         }
         [aMBProgressHUD removeFromSuperview];
     } timeoutBlock:^(MiaRequestItem *requestItem) {
         [aMBProgressHUD removeFromSuperview];
         [HXAlertBanner showWithMessage:@"分享失败，网络请求超时" tap:nil];
     }];
}

- (IBAction)addMusicButtonPressed {
    if (!_searchViewController) {
        _searchViewController = [[SearchViewController alloc] init];
        _searchViewController.delegate = self;
    }
    [self presentViewController:_searchViewController animated:YES completion:nil];
}

- (IBAction)playButtonPressed {
	if ([[MusicMgr standard] isPlayingWithUrl:_dataItem.songUrl]) {
		[[MusicMgr standard] pause];
		[_playButton setImage:[UIImage imageNamed:@"M-PauseIcon"] forState:UIControlStateNormal];
	} else {
		[self playMusic];
	}
}

- (IBAction)resetButtonPressed {
    [self addMusicButtonPressed];
}

- (IBAction)closeLocationPressed {
    _closeLocation = YES;
    _locationView.hidden = YES;
}

- (IBAction)tapGesture {
    [self.view endEditing:YES];
}

- (void)keyBoardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    //获取当前显示的键盘高度
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey ] CGRectValue].size;
    [self showKeyboardWithSize:keyboardSize];
}

- (void)keyBoardWillHide:(NSNotification *)notification {
    [self hiddenKeyboard];
}


#pragma mark - audio operations
- (void)playMusic {
    if (!_musicItem.murl || !_musicItem.name || !_musicItem.singerName) {
        NSLog(@"Music is nil, stop play it.");
        return;
    }

	ShareItem *itemForPlay = [[ShareItem alloc] init];
	itemForPlay.sID = kDefaultShareID;
	itemForPlay.music = _musicItem;
	[[MusicMgr standard] setPlayListWithItem:itemForPlay hostObject:self];
	[[MusicMgr standard] playCurrent];

	[_playButton setImage:[UIImage imageNamed:@"M-PauseIcon"] forState:UIControlStateNormal];
}

- (void)pauseMusic {
	[[MusicMgr standard] pause];
    [_playButton setImage:[UIImage imageNamed:@"M-PlayIcon"] forState:UIControlStateNormal];
}

- (void)stopMusic {
	if (![[MusicMgr standard] isCurrentHostObject:self]) {
		return;
	}

	[[MusicMgr standard] stop];
    [_playButton setImage:[UIImage imageNamed:@"M-PlayIcon"] forState:UIControlStateNormal];
}

#pragma mark - Private Methods
- (void)startUpdatingLocation {
    __weak __typeof__(self)weakSelf = self;
    [[LocationMgr standard] startUpdatingLocationWithOnceBlock:^(CLLocationCoordinate2D coordinate, NSString *address) {
        __strong __typeof__(self)strongSelf = weakSelf;
        if (address.length) {
            _coordinate = coordinate;
            _address = address;
            strongSelf.locationLabel.text = address;
        }
    }];
}

- (void)showKeyboardWithSize:(CGSize)keyboardSize {
    _scrollViewBottmonConstraint.constant = keyboardSize.height - _locationViewHeightConstraint.constant;
    [self.view layoutIfNeeded];
    [self scrollToBottomWithAnimation:YES];
}

- (void)hiddenKeyboard {
    _scrollViewBottmonConstraint.constant = 0.0f;
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:1.0f animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf.view layoutIfNeeded];
    }];
}

- (void)scrollToBottomWithAnimation:(BOOL)animated {
    CGPoint bottomOffset = CGPointMake(0, _scrollView.contentSize.height - _scrollView.bounds.size.height);
    [_scrollView setContentOffset:bottomOffset animated:animated];
}

- (void)updateUI {
    _addMusicButton.enabled = NO;
    _frontCoverView.hidden = NO;
    [_frontCover sd_setImageWithURL:[NSURL URLWithString:_dataItem.albumPic] placeholderImage:[UIImage imageNamed:@"default_cover"]];
    
    _songNameLabel.text = _dataItem.title;
    _singerLabel.text = _dataItem.artist;

	if ([[MusicMgr standard] isPlayingWithUrl:_dataItem.songUrl]) {
		[_playButton setImage:[UIImage imageNamed:@"M-PauseIcon"] forState:UIControlStateNormal];
	} else {
		[_playButton setImage:[UIImage imageNamed:@"M-PlayIcon"] forState:UIControlStateNormal];
	}

    [MiaAPIHelper getMusicById:_dataItem.songID
                 completeBlock:
     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
         NSLog(@"GetMusicById %d", success);
     } timeoutBlock:^(MiaRequestItem *requestItem) {
         NSLog(@"GetMusicById timeout");
     }];
}

- (void)startAnimation {
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf.songNameLabel.alpha = 1.0f;
        strongSelf.singerLabel.alpha = 1.0f;
    } completion:nil];
    
    _frontCoverTopConstraint.constant = 115.0f;
    [UIView animateWithDuration:0.8f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf.shareButton.enabled = YES;
    }];
}

#pragma mark - SearchViewControllerDelegate Methods
- (void)searchViewControllerDidSelectedItem:(SearchResultItem *)item {
    _dataItem = item;
    
    _musicItem.singerName = _dataItem.artist;
    _musicItem.albumName = _dataItem.albumName;
    _musicItem.name = _dataItem.title;
    _musicItem.purl = _dataItem.albumPic;
    _musicItem.murl = _dataItem.songUrl;
    
    [self updateUI];
	
	[self bs_performBlock:^{
		[_commentTextView becomeFirstResponder];
	} afterDelay:0.5f];
}

- (void)searchViewControllerWillDismiss {
    ;
}

- (void)searchViewControllerDismissFinished {
    _resetButton.hidden = NO;
    [self startAnimation];
}

- (void)searchViewControllerClickedPlayButtonAtItem:(SearchResultItem *)item {
    if (_dataItem && [item.songUrl isEqualToString:_dataItem.songUrl]) {
        [self pauseMusic];
    } else {
        _dataItem = item;
        _musicItem.singerName = _dataItem.artist;
        _musicItem.albumName = _dataItem.albumName;
        _musicItem.name = _dataItem.title;
        _musicItem.purl = _dataItem.albumPic;
        _musicItem.murl = _dataItem.songUrl;
        
        [self playMusic];
    }
}

#pragma mark - HXTextViewDelegate Methods
- (void)textViewSizeChanged:(CGSize)size {
    _textViewHeightConstraint.constant = (size.height > 50.0f) ? size.height : 50.0f;
    [self scrollToBottomWithAnimation:YES];
}

#pragma mark - Notification Methods
- (void)notificationPlayerEvent:(NSNotification *)notification {
	NSString *sID = notification.userInfo[MusicMgrNotificationKey_sID];
	MiaPlayerEvent event = [notification.userInfo[MusicMgrNotificationKey_PlayerEvent] unsignedIntegerValue];

	if (![kDefaultShareID isEqualToString:sID]) {
		return;
	}
	
	switch (event) {
		case MiaPlayerEventDidPlay:
			    [_playButton setImage:[UIImage imageNamed:@"M-PauseIcon"] forState:UIControlStateNormal];
			break;
		case MiaPlayerEventDidPause:
			    [_playButton setImage:[UIImage imageNamed:@"M-PlayIcon"] forState:UIControlStateNormal];
			break;
		case MiaPlayerEventDidCompletion:
			[_playButton setImage:[UIImage imageNamed:@"M-PlayIcon"] forState:UIControlStateNormal];
			[_searchViewController playCompletion];
			break;
		default:
			NSLog(@"It's a bug, sID: %@, PlayerEvent: %lu", sID, (unsigned long)event);
			break;
	}
}

@end
