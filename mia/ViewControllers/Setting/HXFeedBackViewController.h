//
//  HXFeedBackViewController.h
//  mia
//
//  Created by miaios on 15/10/21.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BRPlaceholderTextView;

NS_ASSUME_NONNULL_BEGIN

@interface HXFeedBackViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet              UIButton *sendButton;
@property (weak, nonatomic) IBOutlet BRPlaceholderTextView *feedContentTextView;
@property (weak, nonatomic) IBOutlet           UITextField *feedContactTextField;

+ (instancetype)instance;

- (IBAction)backButtonPressed;
- (IBAction)sendButtonPressed;

NS_ASSUME_NONNULL_END

@end
