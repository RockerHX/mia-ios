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

@end

@interface HXBubbleView : UIView <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet         id  <HXBubbleViewDelegate>delegate;

@property (nonatomic, weak) IBOutlet    UILabel *promptLabel;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet   UIButton *sendButton;

- (IBAction)sendButtonPressed;

- (void)reset;

@end
