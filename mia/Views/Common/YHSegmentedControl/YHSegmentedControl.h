//
//  YHSegmentedControl.h
//  CustomSegControlView
//
//  Created by linyehui on 2016-01-27.
//  Copyright (c) 2016年 linyehui. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YHSegmentedControlDelegate <NSObject>

@required
- (void)YHSegmentedControlSelected:(NSInteger)index;

@end

@interface YHSegmentedControl : UIView

@property (assign, nonatomic) id<YHSegmentedControlDelegate> delegate;

- (id)initWithHeight:(CGFloat)height titles:(NSArray *)titles delegate:(id)delegate;

- (void)switchToIndex:(NSInteger)index;
- (void)setTitle:(NSString *)title forIndex:(NSInteger)index;

@end
