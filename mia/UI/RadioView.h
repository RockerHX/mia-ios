//
//  RadioView.h
//  mia
//
//  Created by linyehui on 2015/09/09.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RadioViewDelegate

@end


@interface RadioView : UIView

@property (weak, nonatomic)id<RadioViewDelegate> radioViewDelegate;

- (void)spreadFeed;
- (void)skipFeed;

@end
