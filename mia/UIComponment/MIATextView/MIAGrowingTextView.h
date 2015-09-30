//
//  MIAGrowingTextView.h
//  mia
//
//  Created by mia on 14-8-12.
//  Copyright (c) 2014年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MIAGrowingTextView;
@class MIATextViewInternal;

@protocol MIAGrowingTextViewDelegate

@optional
- (BOOL)growingTextViewShouldBeginEditing:(MIAGrowingTextView *)growingTextView;
- (BOOL)growingTextViewShouldEndEditing:(MIAGrowingTextView *)growingTextView;

- (void)growingTextViewDidBeginEditing:(MIAGrowingTextView *)growingTextView;
- (void)growingTextViewDidEndEditing:(MIAGrowingTextView *)growingTextView;

- (BOOL)growingTextView:(MIAGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)growingTextViewDidChange:(MIAGrowingTextView *)growingTextView;

- (void)growingTextView:(MIAGrowingTextView *)growingTextView willChangeHeight:(float)height;
- (void)growingTextView:(MIAGrowingTextView *)growingTextView didChangeHeight:(float)height;

- (void)growingTextViewDidChangeSelection:(MIAGrowingTextView *)growingTextView;
- (BOOL)growingTextViewShouldReturn:(MIAGrowingTextView *)growingTextView;
@end

@interface MIAGrowingTextView : UIView <UITextViewDelegate>{

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
@property (retain, nonatomic) MIATextViewInternal *internalTextView;

@property (assign) NSObject<MIAGrowingTextViewDelegate> *delegate;
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










