//
//  HJWRefreshHeaderView.m
//  huanjuwan
//
//  Created by huanjuwan on 14-8-6.
//  Copyright (c) 2014年 duowan. All rights reserved.
//

#import "HJWRefreshHeaderView.h"
#import "UIView+Extension.h"
#import "UIScrollView+Extension.h"

@interface HJWRefreshHeaderView()

// 最后的更新时间
@property (nonatomic, strong) NSDate *lastUpdateTime;
@property (nonatomic, weak) UILabel *lastUpdateTimeLabel;

@end

@implementation HJWRefreshHeaderView

NSString *const HJWRefreshHeaderPullToRefresh               = @"上拉可以刷新";
NSString *const HJWRefreshHeaderReleaseToRefresh            = @"松开立即刷新";
NSString *const HJWRefreshHeaderRefreshing                  = @"正在刷新中...";
NSString *const HJWRefreshHeaderTimeKey                     = @"HJWRefreshHeaderView";
static const NSString *HJWRefreshContentOffset              = @"contentOffset";
static CGFloat HJWRefreshSlowAnimationDuration              = 0.4;
static CGFloat HJWRefreshFastAnimationDuration              = 0.25;

#pragma mark - 控件初始化
/**
 *  时间标签
 */
- (UILabel *)lastUpdateTimeLabel
{
    if (!_lastUpdateTimeLabel) {
        // 创建控件
        UILabel *lastUpdateTimeLabel = [[UILabel alloc] init];
        lastUpdateTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        lastUpdateTimeLabel.font = [UIFont boldSystemFontOfSize:12];
        lastUpdateTimeLabel.textColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0];
        lastUpdateTimeLabel.backgroundColor = [UIColor clearColor];
        lastUpdateTimeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_lastUpdateTimeLabel = lastUpdateTimeLabel];
        
        // 加载时间
        self.lastUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:HJWRefreshHeaderTimeKey];
    }
    return _lastUpdateTimeLabel;
}

+ (instancetype)header
{
    return [[HJWRefreshHeaderView alloc] init];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat statusX = 0;
    CGFloat statusY = 0;
    CGFloat statusHeight = self.height * 0.5;
    CGFloat statusWidth = self.width;
    // 状态标签
    self.statusLabel.frame = CGRectMake(statusX, statusY, statusWidth, statusHeight);
    
    // 时间标签
    CGFloat lastUpdateY = statusHeight;
    CGFloat lastUpdateX = 0;
    CGFloat lastUpdateHeight = statusHeight;
    CGFloat lastUpdateWidth = statusWidth;
    self.lastUpdateTimeLabel.frame = CGRectMake(lastUpdateX, lastUpdateY, lastUpdateWidth, lastUpdateHeight);
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    // 设置自己的位置和尺寸
    self.y = - self.height;
}

#pragma mark - 状态相关
#pragma mark 设置最后的更新时间
- (void)setLastUpdateTime:(NSDate *)lastUpdateTime
{
    _lastUpdateTime = lastUpdateTime;
    
    [[NSUserDefaults standardUserDefaults] setObject:lastUpdateTime forKey:HJWRefreshHeaderTimeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 更新时间
    [self updateTimeLabel];
}

#pragma mark 更新时间字符串
- (void)updateTimeLabel
{
    if (!self.lastUpdateTime) return;
    
    // 1.获得年月日
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents *cmp1 = [calendar components:unitFlags fromDate:_lastUpdateTime];
    NSDateComponents *cmp2 = [calendar components:unitFlags fromDate:[NSDate date]];
    
    // 2.格式化日期
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if ([cmp1 day] == [cmp2 day]) { // 今天
        formatter.dateFormat = @"今天 HH:mm";
    } else if ([cmp1 year] == [cmp2 year]) { // 今年
        formatter.dateFormat = @"MM-dd HH:mm";
    } else {
        formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    }
    NSString *time = [formatter stringFromDate:self.lastUpdateTime];
    
    // 3.显示日期
    self.lastUpdateTimeLabel.text = [NSString stringWithFormat:@"最后更新：%@", time];
}

#pragma mark - 监听UIScrollView的contentOffset属性
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (!self.userInteractionEnabled || self.alpha <= 0.01 || self.hidden)
        return;
    
    if (self.state == HJWRefreshStateRefreshing)
        return;
    
    if ([HJWRefreshContentOffset isEqualToString:keyPath]) {
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
    // 头部控件刚好出现的offsetY
    CGFloat happenOffsetY = - self.scrollViewOriginalInset.top;
    
    // 如果是向上滚动到看不见头部控件，直接返回
    if (currentOffsetY >= happenOffsetY)
        return;
    
    if (self.scrollView.isDragging) {
        // 普通 和 即将刷新 的临界点
        CGFloat normal2pullingOffsetY = happenOffsetY - self.height;
        
        if (self.state == HJWRefreshStateNormal && currentOffsetY < normal2pullingOffsetY) {
            // 转为即将刷新状态
            self.state = HJWRefreshStatePulling;
        } else if (self.state == HJWRefreshStatePulling && currentOffsetY >= normal2pullingOffsetY) {
            // 转为普通状态
            self.state = HJWRefreshStateNormal;
        }
    } else if (self.state == HJWRefreshStatePulling) {// 即将刷新 && 手松开
        // 开始刷新
        self.state = HJWRefreshStateRefreshing;
    }
}

#pragma mark 设置状态
- (void)setState:(HJWRefreshState)state{
    if (self.state == state)
        return;
    
    HJWRefreshState oldState = self.state;
    
    [super setState:state];

	switch (state) {
		case HJWRefreshStateNormal: // 下拉可以刷新
        {
            // 设置文字
			self.statusLabel.text = HJWRefreshHeaderPullToRefresh;
            
            // 刷新完毕
            if (HJWRefreshStateRefreshing == oldState) {
                self.arrowImage.transform = CGAffineTransformIdentity;
                // 保存刷新时间
                self.lastUpdateTime = [NSDate date];
                
                [UIView animateWithDuration:HJWRefreshSlowAnimationDuration animations:^{
                    self.scrollView.contentInsetTop = self.scrollViewOriginalInset.top;
                }];
            } else {
                // 执行动画
                [UIView animateWithDuration:HJWRefreshFastAnimationDuration animations:^{
                    self.arrowImage.transform = CGAffineTransformIdentity;
                }];
            }
			break;
        }
            
		case HJWRefreshStatePulling: // 松开可立即刷新
        {
            // 设置文字
            self.statusLabel.text = HJWRefreshHeaderReleaseToRefresh;
            // 执行动画
            [UIView animateWithDuration:HJWRefreshFastAnimationDuration animations:^{
                self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
            }];
			break;
        }
            
		case HJWRefreshStateRefreshing: // 正在刷新中
        {
            // 设置文字
            self.statusLabel.text = HJWRefreshHeaderRefreshing;
            
            // 执行动画
            [UIView animateWithDuration:HJWRefreshFastAnimationDuration animations:^{
                // 增加滚动区域
                CGFloat top = self.scrollViewOriginalInset.top + self.height;
                self.scrollView.contentInsetTop = top;
                
                // 设置滚动位置
                self.scrollView.contentOffsetY = - top;
            }];
			break;
        }
            
        default:
            break;
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
