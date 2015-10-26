//
//  HXMusicDetailViewController.m
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXMusicDetailViewController.h"
#import "HXMusicDetailView.h"
#import "ShareItem.h"
#import "UIActionSheet+Blocks.h"
#import "MiaAPIHelper.h"
#import "HXAlertBanner.h"

@interface HXMusicDetailViewController ()

@end

@implementation HXMusicDetailViewController

#pragma mark - View Controller Life Cycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initConfig];
    [self viewConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
    
}

- (void)viewConfig {
    [self refresh];
}

#pragma mark - Event Response
- (IBAction)moreButtonPressed {
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"取消" action:^{
        NSLog(@"cancel");
    }];
    
    RIButtonItem *reportItem = [RIButtonItem itemWithLabel:@"举报" action:^{
        [MiaAPIHelper reportShareById:_playItem.sID completeBlock:
         ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
             if (success) {
                 [HXAlertBanner showWithMessage:@"举报成功" tap:nil];
             } else {
                 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
                 [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"举报失败:%@", error] tap:nil];
             }
         } timeoutBlock:^(MiaRequestItem *requestItem) {
             [HXAlertBanner showWithMessage:@"举报失败，网络请求超时" tap:nil];
         }];
    }];
    
    RIButtonItem *deleteItem = [RIButtonItem itemWithLabel:@"删除" action:^{
        [MiaAPIHelper deleteShareById:_playItem.sID completeBlock:
         ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
             if (success) {
                 [HXAlertBanner showWithMessage:@"删除成功" tap:nil];
                 [self.navigationController popViewControllerAnimated:YES];
//                 [_detailHeaderView stopMusic];
//                 
//                 if (_customDelegate) {
//                     [_customDelegate detailViewControllerDidDeleteShare];
//                 }
             } else {
                 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
                 [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"删除失败:%@", error] tap:nil];
             }
         } timeoutBlock:^(MiaRequestItem *requestItem) {
             [HXAlertBanner showWithMessage:@"删除失败，网络请求超时" tap:nil];
         }];
        
    }];
    
    UIActionSheet *aActionSheet = nil;
    if (_formProfile) {
        aActionSheet = [[UIActionSheet alloc] initWithTitle:@"更多操作"
                                           cancelButtonItem:cancelItem
                                      destructiveButtonItem:reportItem
                                           otherButtonItems:deleteItem, nil];
    } else {
        aActionSheet = [[UIActionSheet alloc] initWithTitle:@"更多操作"
                                           cancelButtonItem:cancelItem
                                      destructiveButtonItem:reportItem
                                           otherButtonItems:nil];
    }
    
    [aActionSheet showInView:self.view];
}

- (IBAction)commentButtonPressed {
    
}

#pragma mark - Private Methods
- (void)refresh {
    [_detailView refreshWithItem:_playItem];
}

@end