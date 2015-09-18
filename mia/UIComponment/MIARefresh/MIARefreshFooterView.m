//
//  MIARefreshFooterView.m
//  mia
//
//  Created by mia on 14-8-6.
//  Copyright (c) 2014年 duowan. All rights reserved.
//

#import "MIARefreshFooterView.h"
#import "UIView+Extension.h"
#import "UIScrollView+Extension.h"

@interface MIARefreshFooterView()
@property (assign, nonatomic) int lastRefreshCount;
@end

@implementation MIARefreshFooterView

NSString *const MIARefreshFooterPullToRefresh               = @"上拉可以加载更多数据";
NSString *const MIARefreshFooterReleaseToRefresh            = @"松开立即加载更多数据";
NSString *const MIARefreshFooterRefreshing                  = @"正在加载中...";
NSString *const MIARefreshContentSize                       = @"contentSize";
static const NSString *MIARefreshContentOffset              = @"contentOffset";
static const CGFloat MIARefreshSlowAnimationDuration        = 0.4;
static const CGFloat MIARefreshFastAnimationDuration        = 0.25;

+ (instancetype)footer
{
    return [[MIARefreshFooterView alloc] init];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.statusLabel.frame = self.bounds;
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    
    [self.superview removeObserver:self forKeyPath:MIARefreshContentSize context:nil];
    
    if (newSuperview) {
        [newSuperview addObserver:self forKeyPath:MIARefreshContentSize options:NSKeyValueObservingOptionNew context:nil];

        [self adjustFrameWithContentSize];
    }
}

/**
 *  重写调整frame
 */
- (void)adjustFrameWithContentSize{
    // 内容的高度
    CGFloat contentHeight = self.scrollView.contentSizeHeight;
    // 表格的高度
    CGFloat scrollHeight = self.scrollView.height - self.scrollViewOriginalInset.top - self.scrollViewOriginalInset.bottom;
    // 设置位置和尺寸
    self.y = MAX(contentHeight, scrollHeight);
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    // 不能跟用户交互，直接返回
    if (!self.userInteractionEnabled || self.alpha <= 0.01 || self.hidden) return;
    
    if ([MIARefreshContentSize isEqualToString:keyPath]) {
        // 调整frame
        [self adjustFrameWithContentSize];
    } else if ([MIARefreshContentOffset isEqualToString:keyPath]) {
        // 如果正在刷新，直接返回
        if (self.state == MIARefreshStateRefreshing) return;
        
        // 调整状态
        [self adjustStateWithContentOffset];
    }
}

/**
 *  调整状态
 */
- (void)adjustStateWithContentOffset
{
    // 当前的contentOffset
    CGFloat currentOffsetY = self.scrollView.contentOffsetY;
    // 尾部控件刚好出现的offsetY
    CGFloat happenOffsetY = [self happenOffsetY];
    
    // 如果是向下滚动到看不见尾部控件，直接返回
    if (currentOffsetY <= happenOffsetY) return;
    
    if (self.scrollView.isDragging) {
        // 普通 和 即将刷新 的临界点
        CGFloat normal2pullingOffsetY = happenOffsetY + self.height;
        
        if (self.state == MIARefreshStateNormal && currentOffsetY > normal2pullingOffsetY) {
            // 转为即将刷新状态
            self.state = MIARefreshStatePulling;
        } else if (self.state == MIARefreshStatePulling && currentOffsetY <= normal2pullingOffsetY) {
            // 转为普通状态
            self.state = MIARefreshStateNormal;
        }
    } else if (self.state == MIARefreshStatePulling) {// 即将刷新 && 手松开
        // 开始刷新
        self.state = MIARefreshStateRefreshing;
    }
}

/**
 *  设置状态
 *
 */
- (void)setState:(MIARefreshState)state{
    if (self.state == state) return;
    
    MIARefreshState oldState = self.state;
    
    [super setState:state];
    
	switch (state)
    {
		case MIARefreshStateNormal:
        {
            // 设置文字
            self.statusLabel.text = MIARefreshFooterPullToRefresh;
            
            // 刷新完毕
            if (MIARefreshStateRefreshing == oldState) {
                self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
                [UIView animateWithDuration:MIARefreshSlowAnimationDuration animations:^{
                    self.scrollView.contentInsetBottom = self.scrollViewOriginalInset.bottom;
                }];
            } else {
                // 执行动画
                [UIView animateWithDuration:MIARefreshFastAnimationDuration animations:^{
                    self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
                }];
            }
            
            CGFloat deltaH = [self heightForContentBreakView];
            int currentCount = [self totalDataCountInScrollView];
            // 刚刷新完毕
            if (MIARefreshStateRefreshing == oldState && deltaH > 0 && currentCount != self.lastRefreshCount) {
                self.scrollView.contentOffsetY = self.scrollView.contentOffsetY;
            }
			break;
        }
            
		case MIARefreshStatePulling:
        {
            // 设置文字
            self.statusLabel.text = MIARefreshFooterReleaseToRefresh;
            
            [UIView animateWithDuration:MIARefreshFastAnimationDuration animations:^{
                self.arrowImage.transform = CGAffineTransformIdentity;
            }];
			break;
        }
            
        case MIARefreshStateRefreshing:
        {
            // 设置文字
            self.statusLabel.text = MIARefreshFooterRefreshing;
            
            // 记录刷新前的数量
            self.lastRefreshCount = [self totalDataCountInScrollView];
            
            [UIView animateWithDuration:MIARefreshFastAnimationDuration animations:^{
                CGFloat bottom = self.height + self.scrollViewOriginalInset.bottom;
                CGFloat deltaH = [self heightForContentBreakView];
                if (deltaH < 0) {
                    // 如果内容高度小于view的高度
                    bottom -= deltaH;
                }
                self.scrollView.contentInsetBottom = bottom;
            }];
			break;
        }
            
        default:
            break;
	}
}

- (int)totalDataCountInScrollView
{
    int totalCount = 0;
    if ([self.scrollView isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self.scrollView;
        
        for (int section = 0; section<tableView.numberOfSections; section++) {
            totalCount += [tableView numberOfRowsInSection:section];
        }
    } else if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self.scrollView;
        
        for (int section = 0; section<collectionView.numberOfSections; section++) {
            totalCount += [collectionView numberOfItemsInSection:section];
        }
    }
    return totalCount;
}

- (CGFloat)heightForContentBreakView
{
    CGFloat h = self.scrollView.frame.size.height - self.scrollViewOriginalInset.bottom - self.scrollViewOriginalInset.top;
    return self.scrollView.contentSize.height - h;
}

/**
 *  刚好看到上拉刷新控件时的contentOffset.y
 */
- (CGFloat)happenOffsetY
{
    CGFloat deltaH = [self heightForContentBreakView];
    if (deltaH > 0) {
        return deltaH - self.scrollViewOriginalInset.top;
    } else {
        return - self.scrollViewOriginalInset.top;
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


@end
