//
//  HXFeedViewController.m
//  mia
//
//  Created by miaios on 15/10/21.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXFeedViewController.h"
#import "BRPlaceholderTextView.h"

static NSString *FeedContentPrompt = @"欢迎您提出宝贵的意见或建议，我们将为您不断改进。";

@interface HXFeedViewController ()

@end

@implementation HXFeedViewController

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initConfig];
    [self viewConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
    _feedContentTextView.placeholder = FeedContentPrompt;
}

- (void)viewConfig {
    _feedContentTextView.layer.borderWidth = 0.5f;
    _feedContentTextView.layer.borderColor = UIColorFromRGB(230.0f, 230.0f, 230.0f).CGColor;
    
    _feedContactTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 5.0f, 1.0f)];
    _feedContactTextField.leftViewMode = UITextFieldViewModeAlways;
    _feedContactTextField.layer.borderWidth = 0.5f;
    _feedContactTextField.layer.borderColor = UIColorFromRGB(230.0f, 230.0f, 230.0f).CGColor;
}

#pragma mark - Event Response
- (IBAction)sendButtonPressed {
    [self userFeedBackReuqestWithContact:_feedContactTextField.text content:_feedContentTextView.text];
}

#warning User Feed Back Request Add Here
#pragma mark - Private Methods
- (void)userFeedBackReuqestWithContact:(NSString *)contact content:(NSString *)content {
    
}

@end
