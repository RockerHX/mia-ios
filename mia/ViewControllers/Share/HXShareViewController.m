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

@interface HXShareViewController () <SearchViewControllerDelegate, HXTextViewDelegate>
@end

@implementation HXShareViewController {
    MusicItem *_musicItem;
    SongListPlayer *_songListPlayer;
    SearchResultItem *_dataItem;
}

#pragma mark - View Controller Life Cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initConfig];
    [self viewConfig];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Config Methods
- (void)initConfig {
    _scrollView.scrollsToTop = YES;
    _commentTextView.scrollsToTop = NO;
    //添加键盘监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewConfig {
    _shareButton.enabled = NO;
    _frontCover.hidden = YES;
    
    _songNameLabel.alpha = 0.0f;
    _singerLabel.alpha = 0.0f;
    
    _nickNameLabel.text = [[UserSession standard] nick];
    _locationLabel.text = @"定位中...";
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
    [MiaAPIHelper postShareWithLatitude:[[LocationMgr standard] currentCoordinate].latitude
                              longitude:[[LocationMgr standard] currentCoordinate].longitude
                                address:[[LocationMgr standard] currentAddress]
                                 songID:_dataItem.songID
                                   note:comment
                          completeBlock:
     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
         if (success) {
             [HXAlertBanner showWithMessage:@"分享成功" tap:nil];
             [self.navigationController popViewControllerAnimated:YES];
         } else {
             id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
             [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"分享失败:%@", error] tap:nil];
         }
         [aMBProgressHUD removeFromSuperview];
     } timeoutBlock:^(MiaRequestItem *requestItem) {
         [aMBProgressHUD removeFromSuperview];
         [HXAlertBanner showWithMessage:@"分享失败，网络请求超时" tap:nil];
     }];
}

- (IBAction)frontCoverPressed {
    SearchViewController *shareViewController = [[SearchViewController alloc] init];
    shareViewController.delegate = self;
    [self presentViewController:shareViewController animated:YES completion:nil];
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

#pragma mark - Public Methods
+ (instancetype)instance {
    return [[UIStoryboard storyboardWithName:@"Share" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([HXShareViewController class])];
}

#pragma mark - Private Methods
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
//    [self scrollToBottom];
}

- (void)scrollToBottomWithAnimation:(BOOL)animated {
    CGPoint bottomOffset = CGPointMake(0, _scrollView.contentSize.height - _scrollView.bounds.size.height);
    [_scrollView setContentOffset:bottomOffset animated:animated];
}

- (void)updateUI {
    _addMusicButton.enabled = NO;
    _frontCover.hidden = NO;
    [_frontCover sd_setImageWithURL:[NSURL URLWithString:_dataItem.albumPic] placeholderImage:[UIImage imageNamed:@"default_cover"]];
    
    _songNameLabel.text = _dataItem.title;
    _singerLabel.text = _dataItem.artist;
    
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
        [strongSelf.commentTextView becomeFirstResponder];
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
}

- (void)searchViewControllerDismissFinished {
    [self startAnimation];
}

- (void)searchViewControllerClickedPlayButtonAtItem:(SearchResultItem *)item {
//    if (_dataItem && [item.songUrl isEqualToString:_dataItem.songUrl]) {
//        [self pauseMusic];
//    } else {
//        _dataItem = item;
//        _musicItem.singerName = _dataItem.artist;
//        _musicItem.albumName = _dataItem.albumName;
//        _musicItem.name = _dataItem.title;
//        _musicItem.purl = _dataItem.albumPic;
//        _musicItem.murl = _dataItem.songUrl;
//        
//        [self playMusic];
//    }
}

#pragma mark - HXTextViewDelegate Methods
- (void)textViewSizeChanged {
    [self scrollToBottomWithAnimation:YES];
}

@end
