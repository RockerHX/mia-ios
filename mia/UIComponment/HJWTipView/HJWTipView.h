//
//  HJWTipView.h
//  huanjuwan
//
//  Created by HongBin Lin on 14-8-15.
//  Copyright (c) 2014年 duowan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HJWTipView : UIView

/**
 *  初始化TipView
 *
 *  @param frame   大小
 *  @param content 文案
 *
 */
-(id)initWithFrame:(CGRect)frame content:(NSString *)content;

/**
 *  更新TipView的提示文案
 *
 *  @param content 新文案
 */
-(void)updateContent:(NSString *)content;

- (id)initMyGambleTipWithFrame:(CGRect)frame content:(NSString *)content buttonTitle:(NSString *)buttonTitle;

@end
