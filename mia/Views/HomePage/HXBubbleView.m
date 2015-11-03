//
//  HXBubbleView.m
//  mia
//
//  Created by miaios on 15/10/15.
//  Copyright © 2015年 miaios. All rights reserved.
//

#import "HXBubbleView.h"

@implementation HXBubbleView {
    BOOL _canTap;
}

#pragma mark - Init Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
    _canTap = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture)];
    [self addGestureRecognizer:tap];
}

#pragma mark - Event Response
- (void)tapGesture {
    if (_canTap) {
        _topPromptLabel.hidden = _canTap;
        _bottomPromptLabel.hidden = _canTap;
        _textView.hidden = !_canTap;
        _sendButton.hidden = !_canTap;
        
        [_textView becomeFirstResponder];
        if (_delegate && [_delegate respondsToSelector:@selector(bubbleViewStartEdit:)]) {
            [_delegate bubbleViewStartEdit:self];
        }
        
        _canTap = !_canTap;
    }
}

- (IBAction)sendButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(bubbleView:shouldSendComment:)]) {
        [_delegate bubbleView:self shouldSendComment:_textView.text];
    }
}

- (IBAction)loginButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(bubbleViewShouldLogin:)]) {
        [_delegate bubbleViewShouldLogin:self];
    }
}

#pragma mark - Public methods
- (void)reset {
    _canTap = YES;
    _textView.text = @"";
    
    _topPromptLabel.hidden = !_canTap;
    _bottomPromptLabel.hidden = !_canTap;
    _textView.hidden = _canTap;
    _sendButton.hidden = _canTap;
}

- (void)showWithLogin:(BOOL)login {
    _canTap = login;
    _loginPromptLabel.hidden = login;
    _loginButton.hidden = login;
    if (!login) {
        _topPromptLabel.hidden = !login;
        _bottomPromptLabel.hidden = !login;
        _textView.hidden = !login;
        _sendButton.hidden = !login;
    } else {
        [self reset];
    }
}

#pragma mark - UITextViewDelegate Methods
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        [self sendButtonPressed];
        return NO;
    }
    return YES;
}

@end
