//
//  HXMiaoPushView.h
//  mia
//
//  Created by miaios on 15/11/17.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXBubbleView;

@interface HXMiaoPushView : UIView

@property (weak, nonatomic) IBOutlet       HXBubbleView *bubbleView;
@property (weak, nonatomic) IBOutlet        UIImageView *fishView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fishBottomConstraint;

@end
