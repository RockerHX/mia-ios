//
//  HJWLabel.h
//  huanjuwan
//
//  Created by huanjuwan on 14-8-4.
//  Copyright (c) 2014年 duowan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class HJWLabel;

@protocol HJWLabelTouchesDelegate <NSObject>

@optional
- (void)label:(HJWLabel *)label touchesWtihTag:(NSInteger)tag;

@end

@interface HJWLabel : UILabel



@property (nonatomic, assign) id <HJWLabelTouchesDelegate> delegate;


/**
 *  自定义初始化UILabel
 *
 *  @param frame         大小
 *  @param text          文案
 *  @param font          字体
 *  @param textColor     文案颜色
 *  @param textAlignment 文案偏移位置
 *  @param numberLines   显示的行数
 *
 */
- (id)initWithFrame:(CGRect)frame text:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor textAlignment:(NSTextAlignment)textAlignment numberLines:(int)numberLines;


@end
