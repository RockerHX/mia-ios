//
//  HXGuideView.m
//  mia
//
//  Created by miaios on 15/10/21.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXGuideView.h"
#import "AppDelegate.h"

typedef void(^BLOCK)(void);

@implementation HXGuideView {
    BLOCK _finishedBlock;
}

#pragma mark - Class Methods
+ (instancetype)showGuide:(void(^)(void))finished {
    HXGuideView *guideView = [[[NSBundle mainBundle] loadNibNamed:@"HXGuideView" owner:self options:nil] firstObject];
    [guideView showGuide:finished];
    return guideView;
}

#pragma mark - Init Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initConfig];
    [self viewConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
}

- (void)viewConfig {
    _locationButton.layer.cornerRadius = _locationButton.frame.size.height/2;
}

#pragma mark - Event Response
- (IBAction)locationButtonPressed {
    if (_finishedBlock) {
        _finishedBlock();
    }
    [self hidden];
}

#pragma mark - Public Methods
- (void)showGuide:(void(^)(void))finished {
    _finishedBlock = finished;
    [self show];
}

- (void)hidden {
    __weak __typeof__(self)weakSelf = self;
    [UIView animateWithDuration:0.8f animations:^{
        __strong __typeof__(self)strongSelf = weakSelf;
        strongSelf.alpha = 0.0f;
    } completion:^(BOOL finished) {
        __strong __typeof__(self)strongSelf = weakSelf;
        [strongSelf removeFromSuperview];
    }];
}

#pragma mark - Private Methods
- (void)show {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    UIWindow *mainWindow = delegate.window;
    self.frame = mainWindow.frame;
    [mainWindow addSubview:self];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat page = scrollView.contentOffset.x/scrollView.frame.size.width;
    _pageControl.currentPage = page;
    if (page > 3.2f) {
        [self locationButtonPressed];
    }
}

@end
