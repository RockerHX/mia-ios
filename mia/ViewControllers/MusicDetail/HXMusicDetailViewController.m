//
//  HXMusicDetailViewController.m
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXMusicDetailViewController.h"
#import "HXMusicDetailContainerViewController.h"
#import "ShareItem.h"
#import "UIActionSheet+BlocksKit.h"
#import "MiaAPIHelper.h"
#import "HXAlertBanner.h"
#import "HXTextView.h"
#import "HXComment.h"
#import "HXUserSession.h"
#import "HXLoadingView.h"

@interface HXMusicDetailViewController () <
HXMusicDetailContainerViewControllerDelegate
>
@end

@implementation HXMusicDetailViewController {
    HXLoadingView *_loadingView;
    HXMusicDetailContainerViewController *_container;
    
    HXMusicDetailViewModel *_viewModel;
    HXComment *_atComment;
}

#pragma mark - Class Methods
+ (HXStoryBoardName)storyBoardName {
    return HXStoryBoardNameMusicDetail;
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    _container = segue.destinationViewController;
    _container.delegate = self;
}

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
    
    [self fetchData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Config Methods
- (void)loadConfigure {
    [self initConfigure];
    [self registerNotification];
}

- (void)initConfigure {
	if (_playItem) {
		_viewModel = [[HXMusicDetailViewModel alloc] initWithItem:_playItem];
	} else if (_sID) {
		_viewModel = [[HXMusicDetailViewModel alloc] initWithID:_sID];
	}
    
    [_viewModel reportViews:nil];
}

- (void)registerNotification {
    //添加键盘监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewConfigure {
    _editCommentView.scrollsToTop = NO;
    
    _loadingView = [HXLoadingView new];
    [_loadingView showOnViewController:self];
    
    if (_showKeyboard) {
        [_editCommentView becomeFirstResponder];
    }
}

#pragma mark - Event Response
- (IBAction)moreButtonPressed {
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:nil];
    [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
    [actionSheet bk_setDestructiveButtonWithTitle:@"举报" handler:^{
        [MiaAPIHelper reportShareById:_viewModel.playItem.sID completeBlock:
         ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
             if (success) {
                 [HXAlertBanner showWithMessage:@"举报成功" tap:nil];
             } else {
                 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
                 [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
             }
         } timeoutBlock:^(MiaRequestItem *requestItem) {
             [HXAlertBanner showWithMessage:@"举报失败，网络请求超时" tap:nil];
         }];
    }];
    
    if (_fromProfile) {
        [actionSheet bk_addButtonWithTitle:@"删除" handler:^{
            [MiaAPIHelper deleteShareById:_viewModel.playItem.sID completeBlock:
             ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
                 if (success) {
                     [HXAlertBanner showWithMessage:@"删除成功" tap:nil];
                     [self.navigationController popViewControllerAnimated:YES];
                     
                     if (_delegate && [_delegate respondsToSelector:@selector(detailViewController:takeAction:)]) {
                         [_delegate detailViewController:self takeAction:HXMusicDetailActionDelete];
                     }
                 } else {
                     id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
                     [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
                 }
             } timeoutBlock:^(MiaRequestItem *requestItem) {
                 [HXAlertBanner showWithMessage:@"删除失败，网络请求超时" tap:nil];
             }];
        }];
    }
    
    [actionSheet showInView:self.view];
}

- (IBAction)commentButtonPressed {
    switch ([HXUserSession share].userState) {
        case HXUserStateLogout: {
            [self shouldLogin];
            break;
        }
        case HXUserStateLogin: {
            _editCommentView.placeholderText = @"";
            _atComment = nil;
            
            [_editCommentView becomeFirstResponder];
            break;
        }
    }
}

- (IBAction)sendButtonPressed {
    NSString *content = _editCommentView.text;
    if (content.length) {
        [_editCommentView resignFirstResponder];
        [self postCommentWithSID:_viewModel.playItem.sID content:content];
    } else {
        [self showBannerWithPrompt:@"评论不能为空"];
    }
}

- (void)keyBoardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    //获取当前显示的键盘高度
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey ] CGRectValue].size;
    [self moveUpViewForKeyboard:keyboardSize];
}

- (void)keyBoardWillHide:(NSNotification *)notification {
    [self resumeView];
}

#pragma mark - Private Methods
- (void)hiddenLoadingView {
    _loadingView.loadState = HXLoadStateSuccess;
}

- (void)fetchData {
    __weak __typeof__(self)weakSelf = self;
    [_viewModel fetchShareItem:^(HXMusicDetailViewModel *viewModel) {
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf->_container.viewModel = viewModel;
        [strongSelf->_container reload];
        
        [viewModel requestComments:^(BOOL success) {
            [strongSelf->_container reload];
        }];
        [self hiddenLoadingView];
    } failure:^(NSString *message) {
        [HXAlertBanner showWithMessage:message tap:nil];
    }];
}

- (void)moveUpViewForKeyboard:(CGSize)keyboardSize {
    [self layoutCommentViewWithHeight:keyboardSize.height];
}

- (void)resumeView {
    [self layoutCommentViewWithHeight:-50.0f];
}

- (void)layoutCommentViewWithHeight:(CGFloat)height {
    __weak __typeof__(self)weakSelf = self;
    _commentViewBottomConstraint.constant = height;
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf.view layoutIfNeeded];
    } completion:nil];
}

- (void)postCommentWithSID:(NSString *)sID content:(NSString *)content {
    [self showBannerWithPrompt:@"正在提交评论..."];
    [MiaAPIHelper postCommentWithShareID:sID
                                 comment:content
							   commentID:(_atComment.cmid ?: nil)
                           completeBlock:
     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
         if (success) {
             _editCommentView.text = @"";
			 _editCommentView.placeholderText = @"";
			 _atComment = nil;
             
             [self requestLatestComments];
             [HXAlertBanner showWithMessage:@"评论成功" tap:nil];
         } else {
             id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
             [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
         }
         [self hiddenHUD];
     } timeoutBlock:^(MiaRequestItem *requestItem) {
         [self hiddenHUD];
         [HXAlertBanner showWithMessage:@"提交评论失败，网络请求超时" tap:nil];
     }];
}

- (void)requestLatestComments {
    __weak __typeof__(self)weakSelf = self;
    [_viewModel requestLatestComments:^(BOOL success) {
        __strong __typeof__(self)strongSelf = weakSelf;
        if (YES) {
            [strongSelf->_container reload];
        }
    }];
}

#pragma mark - HXMusicDetailContainerViewControllerDelegate Methods
- (void)containerViewControllerAtComment:(HXMusicDetailContainerViewController *)container at:(HXComment *)comment {
    [self.view endEditing:YES];
    _atComment = [comment copy];
    _editCommentView.placeholderText = [NSString stringWithFormat:@"回复%@:", _atComment.nickName];
    
    switch ([HXUserSession share].userState) {
        case HXUserStateLogout: {
            [self shouldLogin];
            break;
        }
        case HXUserStateLogin: {
            [_editCommentView becomeFirstResponder];
            break;
        }
    }
}

@end
