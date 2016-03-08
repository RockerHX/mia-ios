//
//  HXGuideView.h
//  mia
//
//  Created by miaios on 15/10/21.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>


FOUNDATION_EXPORT NSString *const kGuideViewShowKey;


@interface HXGuideView : UIView <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet  UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet      UIButton *locationButton;

- (IBAction)locationButtonPressed;


+ (instancetype)showGuide:(void(^)(void))finished;
+ (BOOL)shouldShow;

- (void)showGuide:(void(^)(void))finished;
- (void)hidden;

@end
