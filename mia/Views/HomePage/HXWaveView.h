//
//  HXWaveView.h
//  mia
//
//  Created by miaios on 15/10/14.
//  Copyright © 2015年 miaios. All rights reserved.
//

#import <UIKit/UIKit.h>

//IB_DESIGNABLE
@interface HXWaveView : UIView

@property (nonatomic, assign)    BOOL  attenuation;
@property (nonatomic, assign) CGFloat  vibrationAmplitude;  // M_PI
@property (nonatomic, assign) CGFloat  offsetY;
@property (nonatomic, assign) CGFloat  percent;             // 0 ~ 1, default:0.5f
@property (nonatomic, assign) CGFloat  speed;

- (void)startAnimating;
- (void)stopAnimating;
- (void)reset;

@end
