//
//  MIARefreshBaseView.h
//  mia
//
//  Created by mia on 14-8-6.
//  Copyright (c) 2014年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MIARefreshBaseView;

typedef enum {
	MIARefreshStatePulling          = 1,    // 松开就可以进行刷新的状态
	MIARefreshStateNormal           = 2,    // 普通状态
	MIARefreshStateRefreshing       = 3,    // 正在刷新中的状态
    MIARefreshStateWillRefreshing   = 4
} MIARefreshState;

#pragma mark - 控件的类型
typedef enum {
    MIARefreshViewTypeHeader        = -1,   // 头部控件
    MIARefreshViewTypeFooter        = 1     // 尾部控件
} MIARefreshViewType;

@interface MIARefreshBaseView : UIView


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

@property (assign, nonatomic) MIARefreshState state;
@end







