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
#import "HXAlertBanner.h"

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
    if (_feedContentTextView.text.length) {
        [self userFeedBackReuqestWithContact:_feedContactTextField.text content:_feedContentTextView.text];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                            message:@"请先填写反馈内容才能发送噢！"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
}

#pragma mark - Private Methods
- (void)userFeedBackReuqestWithContact:(NSString *)contact content:(NSString *)content {
	if ([NSString isNull:content]) {
		return;
	}

	[MiaAPIHelper feedbackWithNote:content
						   contact:contact completeBlock:
	 ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
		 if (success) {
			 [HXAlertBanner showWithMessage:@"反馈成功" tap:nil];
			 [self.navigationController popViewControllerAnimated:YES];
		 } else {
			 [HXAlertBanner showWithMessage:@"反馈失败，请稍后重试" tap:nil];
		 }
	 } timeoutBlock:^(MiaRequestItem *requestItem) {
		 [HXAlertBanner showWithMessage:@"反馈超时，请稍后重试" tap:nil];
	}];
}

@end