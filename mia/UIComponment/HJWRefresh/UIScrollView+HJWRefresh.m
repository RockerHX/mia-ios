//
//  UIScrollView+HJWRefresh.m
//  huanjuwan
//
//  Created by huanjuwan on 14-8-6.
//  Copyright (c) 2014年 duowan. All rights reserved.
//

#import "UIScrollView+HJWRefresh.h"
#import "HJWRefreshHeaderView.h"
#import "HJWRefreshFooterView.h"
#import <objc/runtime.h>

@interface UIScrollView()
@property (weak, nonatomic) HJWRefreshHeaderView *header;
@property (weak, nonatomic) HJWRefreshFooterView *footer;
@end

@implementation UIScrollView (HJWRefresh)

#pragma mark - 运行时相关
static char HJWRefreshHeaderViewKey;
static char HJWRefreshFooterViewKey;

- (void)setHeader:(HJWRefreshHeaderView *)header {
    [self willChangeValueForKey:@"HJWRefreshHeaderViewKey"];
    objc_setAssociatedObject(self, &HJWRefreshHeaderViewKey,
                             header,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"HJWRefreshHeaderViewKey"];
}

- (HJWRefreshHeaderView *)header {
    return objc_getAssociatedObject(self, &HJWRefreshHeaderViewKey);
}

- (void)setFooter:(HJWRefreshFooterView *)footer {
    [self willChangeValueForKey:@"HJWRefreshFooterViewKey"];
    objc_setAssociatedObject(self, &HJWRefreshFooterViewKey,
                             footer,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"HJWRefreshFooterViewKey"];
}

- (HJWRefreshFooterView *)footer {
    return objc_getAssociatedObject(self, &HJWRefreshFooterViewKey);
}

#pragma mark - 下拉刷新
/**
 *  添加一个下拉刷新头部控件
 *
 *  @param callback 回调
 */
- (void)addHeaderWithCallback:(void (^)())callback
{
    if (!self.header) {
        HJWRefreshHeaderView *header = [HJWRefreshHeaderView header];
        [self addSubview:header];
        self.header = header;
    }
    
    self.header.beginRefreshingCallback = callback;
}

/**
 *  添加一个下拉刷新头部控件
 *
 *  @param target 目标
 *  @param action 回调方法
 */
- (void)addHeaderWithTarget:(id)target action:(SEL)action
{
    if (!self.header) {
        HJWRefreshHeaderView *header = [HJWRefreshHeaderView header];
        [self addSubview:header];
        self.header = header;
    }
    
    self.header.beginRefreshingTaget = target;
    self.header.beginRefreshingAction = action;
}

/**
 *  移除下拉刷新头部控件
 */
- (void)removeHeader
{
    [self.header removeFromSuperview];
    self.header = nil;
}

/**
 *  主动让下拉刷新头部控件进入刷新状态
 */
- (void)headerBeginRefreshing
{
    [self.header beginRefreshing];
}

/**
 *  让下拉刷新头部控件停止刷新状态
 */
- (void)headerEndRefreshing
{
    [self.header endRefreshing];
}

/**
 *  下拉刷新头部控件的可见性
 */
- (void)setHeaderHidden:(BOOL)hidden
{
    self.header.hidden = hidden;
}

- (BOOL)isHeaderHidden
{
    return self.header.isHidden;
}

#pragma mark - 上拉刷新
/**
 *  添加一个上拉刷新尾部控件
 *
 *  @param callback 回调
 */
- (void)addFooterWithCallback:(void (^)())callback
{
    // 1.创建新的footer
    if (!self.footer) {
        HJWRefreshFooterView *footer = [HJWRefreshFooterView footer];
        [self addSubview:footer];
        self.footer = footer;
    }
    
    // 2.设置block回调
    self.footer.beginRefreshingCallback = callback;
}

/**
 *  添加一个上拉刷新尾部控件
 *
 *  @param target 目标
 *  @param action 回调方法
 */
- (void)addFooterWithTarget:(id)target action:(SEL)action
{
    if (!self.footer) {
        HJWRefreshFooterView *footer = [HJWRefreshFooterView footer];
        [self addSubview:footer];
        self.footer = footer;
    }
    
    self.footer.beginRefreshingTaget = target;
    self.footer.beginRefreshingAction = action;
}

/**
 *  移除上拉刷新尾部控件
 */
- (void)removeFooter
{
    [self.footer removeFromSuperview];
    self.footer = nil;
}

/**
 *  主动让上拉刷新尾部控件进入刷新状态
 */
- (void)footerBeginRefreshing
{
    [self.footer beginRefreshing];
}

/**
 *  让上拉刷新尾部控件停止刷新状态
 */
- (void)footerEndRefreshing
{
    [self.footer endRefreshing];
}

/**
 *  下拉刷新头部控件的可见性
 */
- (void)setFooterHidden:(BOOL)hidden
{
    self.footer.hidden = hidden;
}

- (BOOL)isFooterHidden
{
    return self.footer.isHidden;
}


@end
