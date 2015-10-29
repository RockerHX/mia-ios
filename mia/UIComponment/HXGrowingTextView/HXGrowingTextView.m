//
//  HXGrowingTextView.m
//  mia
//
//  Created by miaios on 15/10/28.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXGrowingTextView.h"

@implementation HXGrowingTextView

#pragma mark - Init Methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initConfig];
        [self viewConfig];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initConfig];
        [self viewConfig];
    }
    return self;
}

#pragma mark - Config Methods
- (void)initConfig {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:self];
}

- (void)viewConfig {
}

#pragma mark - Dealloc Methods
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
}

#pragma mark - Setter And Getter
- (void)setText:(NSString *)text {
    [super setText:text];
    [self updateLayout];
}

#pragma mark - Event Response
- (void)textDidChange:(NSNotification *)notification {
    [self updateLayout];
}

#pragma mark - Public Methods
- (CGSize)intrinsicContentSize {
    CGRect textRect = [self.layoutManager usedRectForTextContainer:self.textContainer];
    CGFloat height = textRect.size.height + self.textContainerInset.top + self.textContainerInset.bottom;
    return CGSizeMake(UIViewNoIntrinsicMetric, height);
}

#pragma mark - Private Methods
- (void)updateLayout {
    [self invalidateIntrinsicContentSize];
    [self scrollRangeToVisible:self.selectedRange];
}

@end
