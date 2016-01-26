//
//  HXFeedBackViewController.h
//  mia
//
//  Created by miaios on 15/10/21.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "UIViewController+HXClass.h"

@class BRPlaceholderTextView;

@interface HXFeedBackViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet              UIButton *sendButton;
@property (weak, nonatomic) IBOutlet BRPlaceholderTextView *feedContentTextView;
@property (weak, nonatomic) IBOutlet           UITextField *feedContactTextField;

- (IBAction)backButtonPressed;
- (IBAction)sendButtonPressed;

@end
