//
//  HJWRefreshBaseView.h
//  huanjuwan
//
//  Created by huanjuwan on 14-8-6.
//  Copyright (c) 2014年 duowan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HJWRefreshBaseView;

typedef enum {
	HJWRefreshStatePulling          = 1,    // 松开就可以进行刷新的状态
	HJWRefreshStateNormal           = 2,    // 普通状态
	HJWRefreshStateRefreshing       = 3,    // 正在刷新中的状态
    HJWRefreshStateWillRefreshing   = 4
} HJWRefreshState;

#pragma mark - 控件的类型
typedef enum {
    HJWRefreshViewTypeHeader        = -1,   // 头部控件
    HJWRefreshViewTypeFooter        = 1     // 尾部控件
} HJWRefreshViewType;

@interface HJWRefreshBaseView : UIView


@property (nonatomic, weak, readonly)   UIScrollView *scrollView;
@property (nonatomic, assign, readonly) UIEdgeInsets scrollViewOriginalInset;


@property (nonatomic, weak, readonly) UILabel *statusLabel;
@property (nonatomic, weak, readonly) UIImageView *arrowImage;
@property (nonatomic, weak, readonly) UIActivityIndicatorView *activityView;


/**
 *  开始进入刷新状态的监听器
 */
@property (weak, nonatomic) id beginRefreshingTaget;
/**
 *  开始进入刷新状态的监听方法
 */
@property (assign, nonatomic) SEL beginRefreshingAction;
/**
 *  开始进入刷新状态就会调用
 */
@property (nonatomic, copy) void (^beginRefreshingCallback)();


/**
 *  是否正在刷新
 */
@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;
/**
 *  开始刷新
 */
- (void)beginRefreshing;
/**
 *  结束刷新
 */
- (void)endRefreshing;

@property (assign, nonatomic) HJWRefreshState state;
@end







