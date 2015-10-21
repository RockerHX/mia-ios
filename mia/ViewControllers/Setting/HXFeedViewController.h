//
//  HXFeedViewController.h
//  mia
//
//  Created by miaios on 15/10/21.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BRPlaceholderTextView;

@interface HXFeedViewController : UIViewController

@property (weak, nonatomic) IBOutlet BRPlaceholderTextView *feedContentTextView;
@property (weak, nonatomic) IBOutlet           UITextField *feedContactTextField;

- (IBAction)sendButtonPressed;

@end
