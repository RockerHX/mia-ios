//
//  HXFeedBackViewController.m
//  mia
//
//  Created by miaios on 15/10/21.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXFeedBackViewController.h"
#import "BRPlaceholderTextView.h"
#import "NSString+IsNull.h"
#import "MiaAPIHelper.h"

static NSString *FeedContentPrompt = @"欢迎您提出宝贵的意见或建议，我们将为您不断改进。";

@interface HXFeedBackViewController ()

@end

@implementation HXFeedBackViewController

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

#warning @andy @"反馈内容是必填的，没有的时候发送按钮不可点击"
#pragma mark - Private Methods
- (void)userFeedBackReuqestWithContact:(NSString *)contact content:(NSString *)content {
	if ([NSString isNull:content]) {
		return;
	}

	[MiaAPIHelper feedbackWithNote:content
						   contact:contact completeBlock:
	 ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
		 [self.navigationController popViewControllerAnimated:YES];
		 // TODO @andy 加提示
		 if (success) {
			 NSLog(@"反馈成功");
		 } else {
			 NSLog(@"反馈失败");
		 }
	 } timeoutBlock:^(MiaRequestItem *requestItem) {
		 // TODO @andy 加提示
		 NSLog(@"反馈失败");
	}];
}

@end
