//
//  HXShareViewController.h
//  mia
//
//  Created by miaios on 15/10/28.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXShareViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet      UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet      UILabel *singerLabel;
@property (weak, nonatomic) IBOutlet      UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet   UITextView *textView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottmonConstraint;

- (IBAction)backButtonPressed;

+ (instancetype)instance;

@end
