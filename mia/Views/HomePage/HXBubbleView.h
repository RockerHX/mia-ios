//
//  HXBubbleView.h
//  mia
//
//  Created by miaios on 15/10/15.
//  Copyright © 2015年 miaios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXBubbleView;

@protocol HXBubbleViewDelegate <NSObject>

@optional
- (void)bubbleViewStartEdit:(HXBubbleView *)bubbleView;
- (void)bubbleView:(HXBubbleView *)bubbleView shouldSendComment:(NSString *)comment;
- (void)bubbleViewShouldLogin:(HXBubbleView *)bubbleView;

@end

@interface HXBubbleView : UIView <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet         id  <HXBubbleViewDelegate>delegate;

@property (nonatomic, weak) IBOutlet    UILabel *promptLabel;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet   UIButton *sendButton;
@property (nonatomic, weak) IBOutlet   UIButton *loginButton;

- (IBAction)sendButtonPressed;
- (IBAction)loginButtonPressed;

- (void)showWithLogin:(BOOL)login;
- (void)reset;

@end
