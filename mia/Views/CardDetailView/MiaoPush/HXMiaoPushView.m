//
//  HXMiaoPushView.m
//  mia
//
//  Created by miaios on 15/11/17.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXMiaoPushView.h"
#import "HXBubbleView.h"
#import "HXVersion.h"
#import "UserSession.h"
#import "MiaAPIHelper.h"
#import "LocationMgr.h"

@implementation HXMiaoPushView {
    BOOL _animating;                // 动画执行标识
    CGFloat _fishViewCenterY;       // 小鱼中心高度位置
    NSTimer *_timer;                // 定时器，用户在妙推动作时默认不评论定时执行结束动画
}

#pragma mark - Config Methods
- (void)initConfig {
    // 初始化小鱼动画帧
    NSMutableArray *fishIcons = @[].mutableCopy;
    for (NSInteger index = 1; index <= 34; index ++) {
        [fishIcons addObject:[UIImage imageNamed:[NSString stringWithFormat:@"fish-%zd", index]]];
    }
    _fishView.animationImages = fishIcons;
    _fishView.animationDuration = 1.5f;
}

- (void)viewConfig {
    [self hanleUnderiPhone6Size];
    [self animationViewConfig];
}

- (void)hanleUnderiPhone6Size {
    if ([HXVersion isIPhone5SPrior]) {
        _fishBottomConstraint.constant = _fishBottomConstraint.constant - 5.0f;
    }
}

- (void)animationViewConfig {
    // 配置气泡的比例和放大锚点；配置妙推用户视图的缩放比例
    _bubbleView.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
    _bubbleView.layer.anchorPoint = CGPointMake(0.4f, 1.0f);
}

#pragma mark - Private Methods
- (void)startAnimation {
    if (!_animating) {
        _animating = YES;
        if ([[UserSession standard] isLogined]) {
            [self infectShare];
        }
        [self startPopFishAnimation];
    }
}

- (void)stopAnimation {
    _animating = NO;
}

- (void)reset {
    [_fishView stopAnimating];
    [_bubbleView reset];
    
    // 重新布局
    _fishBottomConstraint.constant = [HXVersion isIPhone5SPrior] ? 15.0f : 20.0f;
    _fishView.alpha = 1.0f;
    _bubbleView.alpha = 1.0f;
    [self animationViewConfig];
    _fishView.transform = CGAffineTransformIdentity;
    [self layoutIfNeeded];
}

- (void)executeTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.4f target:self selector:@selector(startFinishedAnimation) userInfo:nil repeats:NO];
}

- (void)startPushMusicRequsetWithComment:(NSString *)comment {
//    comment = comment ?: @"";
//    // 用户按钮点击事件，未登录显示登录页面，已登录显示用户信息页面
//    if ([[UserSession standard] isLogined]) {
//        [MiaAPIHelper postCommentWithShareID:_playItem.sID
//                                     comment:comment
//                               completeBlock:
//         ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
//             if (success) {
//                 [HXAlertBanner showWithMessage:@"评论成功" tap:nil];
//             } else {
//                 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
//                 [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
//             }
//         } timeoutBlock:^(MiaRequestItem *requestItem) {
//             [HXAlertBanner showWithMessage:@"提交评论失败，网络请求超时" tap:nil];
//         }];
//        [self startFinishedAnimation];
//    } else {
//        [self presentLoginViewController:nil];
//    }
}

- (void)infectShare {
//    if (!_playItem.isInfected) {
//        _playItem.isInfected = YES;
//        _playItem.infectTotal += 1;
//        
//        __weak __typeof__(self)weakSelf = self;
//        // 传播出去不需要切换歌曲，需要记录下传播的状态和上报服务器
//        [MiaAPIHelper InfectMusicWithLatitude:[[LocationMgr standard] currentCoordinate].latitude
//                                    longitude:[[LocationMgr standard] currentCoordinate].longitude
//                                      address:[[LocationMgr standard] currentAddress]
//                                         spID:_playItem.spID
//                                completeBlock:
//         ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
//             if (success) {
//                 __strong __typeof__(self)strongSelf = weakSelf;
//                 
//                 int isInfected = [userInfo[MiaAPIKey_Values][@"data"][@"isInfected"] intValue];
//                 int infectTotal = [userInfo[MiaAPIKey_Values][@"data"][@"infectTotal"] intValue];
//                 NSArray *infectArray = userInfo[MiaAPIKey_Values][@"data"][@"infectList"];
//                 NSString *spID = [userInfo[MiaAPIKey_Values][@"data"][@"spID"] stringValue];
//                 
//                 if ([spID isEqualToString:strongSelf->_playItem.spID]) {
//                     strongSelf->_playItem.infectTotal = infectTotal;
//                     [strongSelf->_playItem parseInfectUsersFromJsonArray:infectArray];
//                     strongSelf->_playItem.isInfected = isInfected;
//                 }
//             } else {
//                 id error = userInfo[MiaAPIKey_Values][MiaAPIKey_Error];
//                 [HXAlertBanner showWithMessage:[NSString stringWithFormat:@"%@", error] tap:nil];
//             }
//         } timeoutBlock:^(MiaRequestItem *requestItem) {
//             __strong __typeof__(self)strongSelf = weakSelf;
//             strongSelf->_playItem.isInfected = YES;
//             [HXAlertBanner showWithMessage:@"妙推失败，网络请求超时" tap:nil];
//         }];
//    }
}

- (void)cancelLoginOperate {
    [self startFinshAndBubbleHiddenAnimation];
}

- (void)displayWithInfectState:(BOOL)infected {
    BOOL logined = [[UserSession standard] isLogined];
    if (logined) {
        _bubbleView.hidden = infected;
    }
    _fishView.hidden = infected;
}

#pragma mark - Animation
// 小鱼跳出动画
- (void)startPopFishAnimation {
    _fishBottomConstraint.constant = self.frame.size.height/2 - ([HXVersion isIPhone5SPrior] ? 110.0f : 140.0f);
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf.fishView.transform = CGAffineTransformIdentity;
        [strongSelf layoutIfNeeded];
    } completion:nil];
    
    [self startBubbleScaleAnimation];
}

// 气泡弹出动画
- (void)startBubbleScaleAnimation {
    [_bubbleView showWithLogin:[[UserSession standard] isLogined]];
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.5f delay:0.1f usingSpringWithDamping:0.7f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf.bubbleView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if ([[UserSession standard] isLogined]) {
            __strong __typeof__(self)strongSelf = weakSelf;
            [strongSelf executeTimer];
        }
    }];
}

- (void)startFinshAndBubbleHiddenAnimation {
    [_fishView stopAnimating];
    
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.4f animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf.fishView.alpha = 0.0f;
        strongSelf.bubbleView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf->_animating = NO;
        strongSelf.fishBottomConstraint.constant = 20.0f;
    }];
}

// 妙推完成，结束动画
- (void)startFinishedAnimation {
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.8f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        
        // 小鱼转动动画
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformScale(transform, 0.2f, 0.2f);
        transform = CGAffineTransformRotate(transform, -M_PI * 3/4);
        strongSelf.fishView.transform = transform;
        strongSelf.fishView.alpha = 0.0f;
        
        // 气泡缩小动画
        strongSelf.bubbleView.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
        strongSelf.bubbleView.alpha = 0.0f;
        
//        strongSelf.fishView.center = endPont;
//        strongSelf.bubbleView.center = endPont;
    } completion:^(BOOL finished) {
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf stopAnimation];
    }];
}

@end
