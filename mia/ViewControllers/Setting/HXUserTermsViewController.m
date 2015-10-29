//
//  HXUserTermsViewController.m
//  mia
//
//  Created by miaios on 15/10/21.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXUserTermsViewController.h"
#import "MBProgressHUD.h"

static NSString *UserTermsLoadURL = @"http://www.miamusic.com/terms.html";

@implementation HXUserTermsViewController

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initConfig];
    [self viewConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
    _webView.delegate = self;
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:UserTermsLoadURL]]];
}

- (void)viewConfig {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

#pragma mark - Event Response
- (IBAction)iKnowButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIWebViewDelegate Methods
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

@end
