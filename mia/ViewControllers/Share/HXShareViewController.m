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
#import "SongListPlayer.h"
#import "MiaAPIHelper.h"
#import "UIImageView+WebCache.h"
#import "UserSession.h"
#import "HXTextView.h"
#import "MBProgressHUDHelp.h"
#import "LocationMgr.h"
#import "HXAlertBanner.h"
#import "MusicMgr.h"
#import "NSObject+BlockSupport.h"

@interface HXShareViewController () <SearchViewControllerDelegate, HXTextViewDelegate, SongListPlayerDelegate, SongListPlayerDataSource>
@end

@implementation HXShareViewController {
    BOOL 					_closeLocation;
    NSString 				*_address;
    CLLocationCoordinate2D	_coordinate;
    
    MusicItem 				*_musicItem;
    SongListPlayer 			*_songListPlayer;
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
    
    [self initConfig];
    [self viewConfig];
    [self startUpdatingLocation];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

+ (HXStoryBoardName)storyBoardName {
    return HXStoryBoardNameShare;
}

#pragma mark - Config Methods
- (void)initConfig {
    _scrollView.scrollsToTop = YES;
    _commentTextView.scrollsToTop = NO;
    
    [self initData];
    //添加键盘监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)initData {
    _songListPlayer = [[SongListPlayer alloc] initWithModelID:(long)(__bridge void *)self name:@"DetailHeaderView Song List"];
    _songListPlayer.dataSource = self;
    _songListPlayer.delegate = self;
    _musicItem = [[MusicItem alloc] init];
}

- (void)viewConfig {
    _shareButton.enabled = NO;
    
    _songNameLabel.alpha = 0.0f;
    _singerLabel.alpha = 0.0f;
    
    _nickNameLabel.text = [[UserSession standard] nick];
    _locationLabel.text = @"定位中...";
    
    [self configFrontCover];
}

- (void)configFrontCover {
    _frontCoverView.hidden = YES;
    _frontCover.layer.borderColor = UIColorFromHex(@"d7dede", 1.0f).CGColor;
    _frontCover.layer.borderWidth = 0.5f;
}

#pragma mark - Event Response
- (IBAction)backButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

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
    
    [[MusicMgr standard] setCurrentPlayer:_songListPlayer];
    [_songListPlayer playWithMusicItem:_musicItem];
    [_playButton setImage:[UIImage imageNamed:@"M-PauseIcon"] forState:UIControlStateNormal];
}

- (void)pauseMusic {
    [_songListPlayer pause];
    [_playButton setImage:[UIImage imageNamed:@"M-PlayIcon"] forState:UIControlStateNormal];
}

- (void)stopMusic {
    [_songListPlayer stop];
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
- (void)textViewSizeChanged {
    [self scrollToBottomWithAnimation:NO];
}

#pragma mark - SongListPlayerDataSource
- (NSInteger)songListPlayerCurrentItemIndex {
    // 只有一首歌
    return 0;
}

- (NSInteger)songListPlayerNextItemIndex {
    return 0;
}

- (MusicItem *)songListPlayerItemAtIndex:(NSInteger)index {
    // 只有一首歌
    return _musicItem;
}

#pragma mark - SongListPlayerDelegate
- (void)songListPlayerDidPlay {
    [_playButton setImage:[UIImage imageNamed:@"M-PauseIcon"] forState:UIControlStateNormal];
}

- (void)songListPlayerDidPause {
    [_playButton setImage:[UIImage imageNamed:@"M-PlayIcon"] forState:UIControlStateNormal];
}

- (void)songListPlayerDidCompletion {
    [_playButton setImage:[UIImage imageNamed:@"M-PlayIcon"] forState:UIControlStateNormal];
	[_searchViewController playCompletion];
}

@end
