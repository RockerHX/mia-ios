//
//  MIAGrowingTextView.m
//  mia
//
//  Created by mia on 14-8-12.
//  Copyright (c) 2014年 Mia Music. All rights reserved.
//

#import "MIAGrowingTextView.h"
#import "MIATextViewInternal.h"
#import "NSString+Emoji.h"

@interface MIAGrowingTextView(private)

-(void)commonInitialiser;
-(void)resizeTextView:(NSInteger)newSizeH;
-(void)growDidStop;

@end

@implementation MIAGrowingTextView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitialiser:[UIColor grayColor]];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame textColor:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitialiser:color];
    }
    return self;
}

-(void)commonInitialiser:(UIColor *)color
{
    // Initialization code
    CGRect frame = self.frame;
    frame.origin.y = 0;
    frame.origin.x = 0;
    self.internalTextView = [[MIATextViewInternal alloc] initWithFrame:frame];
    self.internalTextView.delegate = self;
    self.internalTextView.scrollEnabled = NO;
    self.internalTextView.font = [UIFont systemFontOfSize:14.0f];
    self.internalTextView.contentInset = UIEdgeInsetsZero;
    self.internalTextView.showsHorizontalScrollIndicator = NO;
    self.internalTextView.backgroundColor = [UIColor whiteColor];
    self.internalTextView.text = @"";
    self.internalTextView.textColor = color;
    [self addSubview:self.internalTextView];
    
    UIView *internal = (UIView*)[[self.internalTextView subviews] objectAtIndex:0];
    minHeight = internal.frame.size.height;
    minNumberOfLines = 1;
    
    _animateHeightChange = YES;
    
    self.internalTextView.text = @"";
    
    [self setMaxNumberOfLines:3];
}

-(void)sizeToFit{
	CGRect r = self.frame;
    if ([self.text length] > 0) {
        return;
    } else {
        r.size.height = minHeight;
        self.frame = r;
    }
}

-(void)setFrame:(CGRect)aframe{
	CGRect r = aframe;
	r.origin.y = 0;
	r.origin.x = contentInset.left;
    r.size.width -= contentInset.left + contentInset.right;
	self.internalTextView.frame = r;
	[super setFrame:aframe];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self performSelector:@selector(textViewDidChange:) withObject:self.internalTextView];
}

-(void)setContentInset:(UIEdgeInsets)inset{
    contentInset = inset;
    
    CGRect r = self.frame;
    r.origin.y = inset.top - inset.bottom;
    r.origin.x = inset.left;
    r.size.width -= inset.left + inset.right;
    
    self.internalTextView.frame = r;
    
    [self setMaxNumberOfLines:maxNumberOfLines];
    [self setMinNumberOfLines:minNumberOfLines];
}

-(UIEdgeInsets)contentInset{
    return contentInset;
}

-(void)setMaxNumberOfLines:(int)n{
    NSString *saveText = self.internalTextView.text, *newText = @"-";
    
    self.internalTextView.delegate = nil;
    self.internalTextView.hidden = YES;
    
    for (int i = 1; i < n; ++i){
        newText = [newText stringByAppendingString:@"\n|W|"];
    }
    self.internalTextView.text = newText;
    
    //    CGRect txtFrame = internalTextView.frame;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        maxHeight = [[NSString stringWithFormat:@"%@\n ",self.internalTextView.text]
                     boundingRectWithSize:CGSizeMake(self.internalTextView.bounds.size.width, CGFLOAT_MAX)
                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                     attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.internalTextView.font,NSFontAttributeName, nil] context:nil].size.height;
    }else{
        maxHeight = self.internalTextView.contentSize.height;
    }
    
    self.internalTextView.text = saveText;
    self.internalTextView.hidden = NO;
    self.internalTextView.delegate = self;
    
    [self sizeToFit];
    maxNumberOfLines = n;
}

-(int)maxNumberOfLines{
    return maxNumberOfLines;
}

-(void)setMinNumberOfLines:(int)m{
    NSString *saveText = self.internalTextView.text, *newText = @"-";
    
    self.internalTextView.delegate = nil;
    self.internalTextView.hidden = YES;
    
    for (int i = 1; i < m; ++i){
        newText = [newText stringByAppendingString:@"\n|W|"];
    }
    self.internalTextView.text = newText;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        minHeight = [[NSString stringWithFormat:@"%@\n ",self.internalTextView.text] boundingRectWithSize:CGSizeMake(self.internalTextView.bounds.size.width, CGFLOAT_MAX)
                                                                                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                                          attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.internalTextView.font,NSFontAttributeName, nil] context:nil].size.height ;
    }else{
        minHeight = self.internalTextView.contentSize.height;
    }
    
    self.internalTextView.text = saveText;
    self.internalTextView.hidden = NO;
    self.internalTextView.delegate = self;
    
    [self sizeToFit];
    
    minNumberOfLines = m;
}

-(int)minNumberOfLines{
    return minNumberOfLines;
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSString *localText = [textView text];
    if([NSString isContainsEmoji:localText]){
        NSRange textRange = [textView selectedRange];
        [textView setText:[NSString disableEmoji:localText]];
        [textView setSelectedRange:textRange];
    }else{
        NSInteger newSizeH ;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            newSizeH = [[NSString stringWithFormat:@"%@\n ",textView.text]
                        boundingRectWithSize:CGSizeMake(textView.bounds.size.width - 10.0f, CGFLOAT_MAX)
                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                        attributes:[NSDictionary dictionaryWithObjectsAndKeys:textView.font,NSFontAttributeName, nil] context:nil].size.height;
        }else{
            newSizeH = textView.contentSize.height;
        }
        
        if(newSizeH < minHeight || !textView.hasText){
            newSizeH = minHeight;
        }
        if (textView.frame.size.height > maxHeight){
            newSizeH = maxHeight;
        }
        if (textView.frame.size.height != newSizeH){
            if (newSizeH > maxHeight && textView.frame.size.height <= maxHeight){
                newSizeH = maxHeight;
            }
            
            if (newSizeH <= maxHeight){
                if(_animateHeightChange) {
                    if ([UIView resolveClassMethod:@selector(animateWithDuration:animations:)]) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
                        [UIView animateWithDuration:0.1f
                                              delay:0
                                            options:(UIViewAnimationOptionAllowUserInteraction|
                                                     UIViewAnimationOptionBeginFromCurrentState)
                                         animations:^(void) {
                                             [self resizeTextView:newSizeH];
                                         }
                                         completion:^(BOOL finished) {
                                             if ([self.delegate respondsToSelector:@selector(growingTextView:didChangeHeight:)]) {
                                                 [self.delegate growingTextView:self didChangeHeight:newSizeH];
                                             }
                                         }];
#endif
                    } else {
                        [UIView beginAnimations:@"" context:nil];
                        [UIView setAnimationDuration:0.1f];
                        [UIView setAnimationDelegate:self];
                        [UIView setAnimationDidStopSelector:@selector(growDidStop)];
                        [UIView setAnimationBeginsFromCurrentState:YES];
                        [self resizeTextView:newSizeH];
                        [UIView commitAnimations];
                    }
                } else {
                    [self resizeTextView:newSizeH];
                    
                    if ([self.delegate respondsToSelector:@selector(growingTextView:didChangeHeight:)]) {
                        [self.delegate growingTextView:self didChangeHeight:newSizeH];
                    }
                }
            }
            
            if (newSizeH >= maxHeight){
                if(!self.internalTextView.scrollEnabled){
                    self.internalTextView.scrollEnabled = YES;
                    [self.internalTextView flashScrollIndicators];
                }
            } else {
                self.internalTextView.scrollEnabled = NO;
            }
        }
        
        
        if ([self.delegate respondsToSelector:@selector(growingTextViewDidChange:)]) {
            [self.delegate growingTextViewDidChange:self];
        }
        
        CGRect line =[textView caretRectForPosition:textView.selectedTextRange.start];
        CGFloat overflow =line.origin.y +line.size.height -(textView.contentOffset.y +textView.bounds.size.height -textView.contentInset.bottom -textView.contentInset.top);
        if (overflow > 0 ) {
            CGPoint offset =textView.contentOffset;
            offset.y += overflow ;
            [textView setContentOffset:offset];
        }
	}
}

-(void)resizeTextView:(NSInteger)newSizeH{
    if ([self.delegate respondsToSelector:@selector(growingTextView:willChangeHeight:)]) {
        [self.delegate growingTextView:self willChangeHeight:newSizeH];
    }
    
    CGRect internalTextViewFrame = self.frame;
    internalTextViewFrame.size.height = newSizeH; // + padding
    self.frame = internalTextViewFrame;
    internalTextViewFrame.origin.y = contentInset.top - contentInset.bottom;
    internalTextViewFrame.origin.x = contentInset.left;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        //        internalTextViewFrame.size.width =  [internalTextView.text
        //                                             boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, internalTextView.bounds.size.height)
        //                                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
        //                                             attributes:[NSDictionary dictionaryWithObjectsAndKeys:internalTextView.font,NSFontAttributeName, nil] context:nil].size.width;
        
        
        //        internalTextViewFrame.size.width =  [[NSString stringWithFormat:@"%@\n ",internalTextView.text]
        //                                            boundingRectWithSize:CGSizeMake(internalTextViewFrame.size.width, CGFLOAT_MAX)
        //                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
        //                                            attributes:[NSDictionary dictionaryWithObjectsAndKeys:internalTextView.font,NSFontAttributeName, nil] context:nil].size.width;
    }else{
        internalTextViewFrame.size.width = self.internalTextView.contentSize.width;
    }
    self.internalTextView.frame = internalTextViewFrame;
}

-(void)growDidStop{
	if ([self.delegate respondsToSelector:@selector(growingTextView:didChangeHeight:)]) {
		[self.delegate growingTextView:self didChangeHeight:self.frame.size.height];
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.internalTextView becomeFirstResponder];
}

- (BOOL)becomeFirstResponder{
    [super becomeFirstResponder];
    return [self.internalTextView becomeFirstResponder];
}

-(BOOL)resignFirstResponder{
	[super resignFirstResponder];
	return [self.internalTextView resignFirstResponder];
}

- (void)dealloc {
//	[internalTextView release];
//    [super dealloc];
}

#pragma mark UITextView properties
-(void)setText:(NSString *)newText{
    self.internalTextView.text = newText;
    [self performSelector:@selector(textViewDidChange:) withObject:self.internalTextView];
}

-(NSString*)text{
    return self.internalTextView.text;
}

-(void)setFont:(UIFont *)afont{
	self.internalTextView.font = afont;
	[self setMaxNumberOfLines:maxNumberOfLines];
	[self setMinNumberOfLines:minNumberOfLines];
}

-(UIFont *)font{
	return self.internalTextView.font;
}

-(void)setTextColor:(UIColor *)color
{
	self.internalTextView.textColor = color;
}

-(UIColor*)textColor{
	return self.internalTextView.textColor;
}

-(void)setTextAlignment:(NSTextAlignment )aligment{
	self.internalTextView.textAlignment = aligment;
}

-(NSTextAlignment)textAlignment{
	return self.internalTextView.textAlignment;
}

-(void)setSelectedRange:(NSRange)range{
	self.internalTextView.selectedRange = range;
}

-(NSRange)selectedRange{
	return self.internalTextView.selectedRange;
}

-(void)setEditable:(BOOL)beditable{
	self.internalTextView.editable = beditable;
}

-(BOOL)isEditable{
	return self.internalTextView.editable;
}

-(void)setReturnKeyType:(UIReturnKeyType)keyType{
	self.internalTextView.returnKeyType = keyType;
}

-(UIReturnKeyType)returnKeyType{
	return self.internalTextView.returnKeyType;
}

-(void)setDataDetectorTypes:(UIDataDetectorTypes)datadetector{
	self.internalTextView.dataDetectorTypes = datadetector;
}

-(UIDataDetectorTypes)dataDetectorTypes{
	return self.internalTextView.dataDetectorTypes;
}

- (BOOL)hasText{
	return [self.internalTextView hasText];
}

- (void)scrollRangeToVisible:(NSRange)range{
	[self.internalTextView scrollRangeToVisible:range];
}

#pragma mark -
#pragma mark UITextViewDelegate



- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	if ([self.delegate respondsToSelector:@selector(growingTextViewShouldBeginEditing:)]) {
		return [self.delegate growingTextViewShouldBeginEditing:self];
		
	} else {
		return YES;
	}
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
	if ([self.delegate respondsToSelector:@selector(growingTextViewShouldEndEditing:)]) {
		return [self.delegate growingTextViewShouldEndEditing:self];
		
	} else {
		return YES;
	}
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
	if ([self.delegate respondsToSelector:@selector(growingTextViewDidBeginEditing:)]) {
		[self.delegate growingTextViewDidBeginEditing:self];
	}
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	if ([self.delegate respondsToSelector:@selector(growingTextViewDidEndEditing:)]) {
		[self.delegate growingTextViewDidEndEditing:self];
	}
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)atext {
	
	if(![textView hasText] && [atext isEqualToString:@""])
        return NO;
	
    if ([self.delegate respondsToSelector:@selector(growingTextView:shouldChangeTextInRange:replacementText:)])
        return [self.delegate growingTextView:self shouldChangeTextInRange:range replacementText:atext];
	
	if ([atext isEqualToString:@"\n"]) {
		if ([self.delegate respondsToSelector:@selector(growingTextViewShouldReturn:)]) {
			if (![self.delegate performSelector:@selector(growingTextViewShouldReturn:) withObject:self]) {
				return YES;
			} else {
				[textView resignFirstResponder];
				return NO;
			}
		}
	}
	return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
	if ([self.delegate respondsToSelector:@selector(growingTextViewDidChangeSelection:)]) {
		[self.delegate growingTextViewDidChangeSelection:self];
	}
}

@end
