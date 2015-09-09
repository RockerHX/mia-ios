//
//  HJWGrowingTextView.h
//  huanjuwan
//
//  Created by huanjuwan on 14-8-12.
//  Copyright (c) 2014年 duowan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HJWGrowingTextView;
@class HJWTextViewInternal;

@protocol HJWGrowingTextViewDelegate

@optional
- (BOOL)growingTextViewShouldBeginEditing:(HJWGrowingTextView *)growingTextView;
- (BOOL)growingTextViewShouldEndEditing:(HJWGrowingTextView *)growingTextView;

- (void)growingTextViewDidBeginEditing:(HJWGrowingTextView *)growingTextView;
- (void)growingTextViewDidEndEditing:(HJWGrowingTextView *)growingTextView;

- (BOOL)growingTextView:(HJWGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)growingTextViewDidChange:(HJWGrowingTextView *)growingTextView;

- (void)growingTextView:(HJWGrowingTextView *)growingTextView willChangeHeight:(float)height;
- (void)growingTextView:(HJWGrowingTextView *)growingTextView didChangeHeight:(float)height;

- (void)growingTextViewDidChangeSelection:(HJWGrowingTextView *)growingTextView;
- (BOOL)growingTextViewShouldReturn:(HJWGrowingTextView *)growingTextView;
@end

@interface HJWGrowingTextView : UIView <UITextViewDelegate>{

    int minHeight;
	int maxHeight;
	
	int maxNumberOfLines;
	int minNumberOfLines;
	
	BOOL _animateHeightChange;
	
	NSString *text;
	UIFont *font;
	UIColor *textColor;
	UITextAlignment textAlignment;
	NSRange selectedRange;
	BOOL editable;
	UIDataDetectorTypes dataDetectorTypes;
	UIReturnKeyType returnKeyType;
    
    UIEdgeInsets contentInset;
}

@property int maxNumberOfLines;
@property int minNumberOfLines;
@property BOOL animateHeightChange;
@property (retain, nonatomic) HJWTextViewInternal *internalTextView;

@property (assign) NSObject<HJWGrowingTextViewDelegate> *delegate;
@property (copy, nonatomic) NSString *text;
@property (retain, nonatomic) UIFont *font;
@property (retain, nonatomic) UIColor *textColor;
@property (nonatomic) NSTextAlignment textAlignment;
@property (nonatomic) NSRange selectedRange;
@property (getter=isEditable, nonatomic) BOOL editable;
@property (nonatomic) UIDataDetectorTypes dataDetectorTypes __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_3_0);
@property (nonatomic) UIReturnKeyType returnKeyType;
@property (assign) UIEdgeInsets contentInset;

- (BOOL)becomeFirstResponder;
- (BOOL)resignFirstResponder;

- (BOOL)hasText;
- (void)scrollRangeToVisible:(NSRange)range;

- (id)initWithFrame:(CGRect)frame textColor:(UIColor *)color;
@end










