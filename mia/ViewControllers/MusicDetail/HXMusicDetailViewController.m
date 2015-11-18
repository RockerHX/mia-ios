//
//  HXMusicDetailViewController.m
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXMusicDetailViewController.h"
#import "HXMusicDetailViewModel.h"
#import "HXMusicDetailCoverCell.h"
#import "HXMusicDetailShareCell.h"
#import "HXMusicDetailInfectCell.h"
#import "HXMusicDetailNoCommentCell.h"
#import "HXMusicDetailCommentCell.h"
#import "ShareItem.h"
#import "UIActionSheet+Blocks.h"
#import "MiaAPIHelper.h"
#import "HXAlertBanner.h"
#import "LoginViewController.h"
#import "UserSession.h"
#import "HXInfectUserListView.h"
#import "InfectItem.h"
#import "LocationMgr.h"
#import "MBProgressHUDHelp.h"
#import "HXGrowingTextView.h"
#import "GuestProfileViewController.h"
#import "FavoriteMgr.h"
#import "HXNavigationController.h"

@interface HXMusicDetailViewController () <HXMusicDetailShareCellDelegate, HXMusicDetailInfectCellDelegate>
@end

@implementation HXMusicDetailViewController {
    HXMusicDetailViewModel *_viewModel;
    
    HXMusicDetailCoverCell *_coverCell;
}

#pragma mark - View Controller Life Cycle
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	[_coverCell stopPlay];
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
    _viewModel = [[HXMusicDetailViewModel alloc] initWithItem:_playItem];
    
//    __weak __typeof__(self)weakSelf = self;
//    [_viewModel requestComments:^(BOOL success) {
//        __strong __typeof__(self)strongSelf = weakSelf;
//        [strongSelf.tableView reloadData];
//    }];
//    [_viewModel reportViews:^(BOOL success) {
//        if (YES) {
//            __strong __typeof__(self)strongSelf = weakSelf;
//            [strongSelf.tableView reloadData];
//        }
//    }];
    
//    //添加键盘监听
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewConfig {
}

#pragma mark - Event Response
- (IBAction)backButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
	if (_delegate && [_delegate respondsToSelector:@selector(detailViewControllerDismissWithoutDelete)]) {
		[_delegate detailViewControllerDismissWithoutDelete];
	}
}

//- (IBAction)moreButtonPressed {
//    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"取消" action:^{
//        NSLog(@"cancel");
//    }];
//    
//    RIButtonItem *reportItem = [RIButtonItem itemWithLabel:@"举报" action:^{
//        [MiaAPIHelper reportShareById:_playItem.sID completeBlock:
//         ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
//             if (success) {
//                 [HXAlertBanner showWithMessage:@"举报成功" tap:nil];
//             } else {
//                 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
//                 [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
//             }
//         } timeoutBlock:^(MiaRequestItem *requestItem) {
//             [HXAlertBanner showWithMessage:@"举报失败，网络请求超时" tap:nil];
//         }];
//    }];
//    
//    RIButtonItem *deleteItem = [RIButtonItem itemWithLabel:@"删除" action:^{
//        [MiaAPIHelper deleteShareById:_playItem.sID completeBlock:
//         ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
//             if (success) {
//                 [HXAlertBanner showWithMessage:@"删除成功" tap:nil];
//                 [self.navigationController popViewControllerAnimated:YES];
//
//                 if (_delegate && [_delegate respondsToSelector:@selector(detailViewControllerDidDeleteShare)]) {
//                     [_delegate detailViewControllerDidDeleteShare];
//                 }
//             } else {
//                 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
//                 [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
//             }
//         } timeoutBlock:^(MiaRequestItem *requestItem) {
//             [HXAlertBanner showWithMessage:@"删除失败，网络请求超时" tap:nil];
//         }];
//        
//    }];
//    
//    UIActionSheet *aActionSheet = nil;
//    if (_fromProfile) {
//        aActionSheet = [[UIActionSheet alloc] initWithTitle:nil
//                                           cancelButtonItem:cancelItem
//                                      destructiveButtonItem:reportItem
//                                           otherButtonItems:deleteItem, nil];
//    } else {
//        aActionSheet = [[UIActionSheet alloc] initWithTitle:nil
//                                           cancelButtonItem:cancelItem
//                                      destructiveButtonItem:reportItem
//                                           otherButtonItems:nil];
//    }
//    
//    [aActionSheet showInView:self.view];
//}
//
//- (IBAction)commentButtonPressed {
//    if ([[UserSession standard] isLogined]) {
//        [_editCommentView becomeFirstResponder];
//    } else {
//        [self presentLoginViewController];
//    }
//}
//
//- (IBAction)sendButtonPressed {
//    [_editCommentView resignFirstResponder];
//    
//    NSString *content = _editCommentView.text;
//    if (content.length) {
//        [self postCommentWithSID:_viewModel.playItem.sID content:content];
//    } else {
//        ;
//    }
//}

//- (void)keyBoardWillShow:(NSNotification *)notification {
//    NSDictionary *info = [notification userInfo];
//    //获取当前显示的键盘高度
//    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey ] CGRectValue].size;
//    [self moveUpViewForKeyboard:keyboardSize];
//}
//
//- (void)keyBoardWillHide:(NSNotification *)notification {
//    [self resumeView];
//}

#pragma mark - Private Methods
//- (void)moveUpViewForKeyboard:(CGSize)keyboardSize {
//    [self layoutCommentViewWithHeight:keyboardSize.height];
//}
//
//- (void)resumeView {
//    [self layoutCommentViewWithHeight:-50.0f];
//}
//
//- (void)layoutCommentViewWithHeight:(CGFloat)height {
//    __weak __typeof__(self)weakSelf = self;
//    _commentViewBottomConstraint.constant = height;
//    [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        __strong __typeof__(self)strongSelf = weakSelf;
//        [strongSelf.view layoutIfNeeded];
//    } completion:nil];
//}
//
//- (void)postCommentWithSID:(NSString *)sID content:(NSString *)content {
//    __weak __typeof__(self)weakSelf = self;
//    MBProgressHUD *aMBProgressHUD = [MBProgressHUDHelp showLoadingWithText:@"正在提交评论"];
//    [MiaAPIHelper postCommentWithShareID:sID
//                                 comment:content
//                           completeBlock:
//     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
//         __strong __typeof__(self)strongSelf = weakSelf;
//         if (success) {
//             strongSelf.editCommentView.text = @"";
//             [strongSelf requestLatestComments];
//             [HXAlertBanner showWithMessage:@"评论成功" tap:nil];
//         } else {
//             id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
//             [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
//         }
//         
//         [aMBProgressHUD removeFromSuperview];
//     } timeoutBlock:^(MiaRequestItem *requestItem) {
//         [aMBProgressHUD removeFromSuperview];
//         [HXAlertBanner showWithMessage:@"提交评论失败，网络请求超时" tap:nil];
//     }];
//}
//
//- (void)requestLatestComments {
//    __weak __typeof__(self)weakSelf = self;
//    [_viewModel requestLatestComments:^(BOOL success) {
//        __strong __typeof__(self)strongSelf = weakSelf;
//        if (YES) {
//            [strongSelf.tableView reloadData];
//        }
//    }];
//}

- (void)tableView:(UITableView *)tableView scrollTableToFoot:(BOOL)animated {
    NSInteger section = [tableView numberOfSections];
    if (section < 1) return;
    NSInteger row = [tableView numberOfRowsInSection:(section - 1)];
    if (row < 1) return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(row - 1) inSection:(section - 1)];
    
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

- (void)presentLoginViewController {
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    HXNavigationController *loginNavigationViewController = [[HXNavigationController alloc] initWithRootViewController:loginViewController];
    [self presentViewController:loginNavigationViewController animated:YES completion:nil];
}

#pragma mark - HXMusicDetailShareCellDelegate Methods
- (void)cellUserWouldLikeSeeSharerInfo:(HXMusicDetailShareCell *)cell {
    ShareItem *playItem = _viewModel.playItem;
    GuestProfileViewController *vc = [[GuestProfileViewController alloc] initWitUID:playItem.uID nickName:playItem.sNick];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - HXMusicDetailInfectCellDelegate Methods
- (void)cellUserWouldLikeShowInfectList:(HXMusicDetailInfectCell *)cell {
    [HXInfectUserListView showWithSharerID:_viewModel.playItem.sID taped:^(id item, NSInteger index) {
        InfectItem *selectedItem = item;
		GuestProfileViewController *vc = [[GuestProfileViewController alloc] initWitUID:selectedItem.uID nickName:selectedItem.nick];
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

@end
