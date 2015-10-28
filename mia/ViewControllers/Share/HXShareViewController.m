//
//  HXShareViewController.m
//  mia
//
//  Created by miaios on 15/10/28.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXShareViewController.h"

@interface HXShareViewController ()
@end

@implementation HXShareViewController

#pragma mark - View Controller Life Cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initConfig];
    [self viewConfig];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Config Methods
- (void)initConfig {
    
    //添加键盘监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewConfig {
}

#pragma mark - Event Response
- (IBAction)backButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)keyBoardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    //获取当前显示的键盘高度
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey ] CGRectValue].size;
//    [self moveUpViewForKeyboard:keyboardSize];
    
    _scrollViewBottmonConstraint.constant = keyboardSize.height;
    [self.view layoutIfNeeded];
//    [_scrollView setContentOffset:CGPointMake(0.0f, _scrollView.contentSize.height) animated:YES];
    CGPoint bottomOffset = CGPointMake(0, _scrollView.contentSize.height - _scrollView.bounds.size.height);
    [_scrollView setContentOffset:bottomOffset animated:YES];
//    __weak __typeof__(self)weakSelf = self;
//    [UIView animateWithDuration:1.0f animations:^{
//        __strong __typeof__(self)strongSelf = weakSelf;
//        [strongSelf.view layoutIfNeeded];
//    }];
}

- (void)keyBoardWillHide:(NSNotification *)notification {
    [self resumeView];
}

#pragma mark - Public Methods
+ (instancetype)instance {
    return [[UIStoryboard storyboardWithName:@"Share" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([HXShareViewController class])];
}

#pragma mark - Private Methods
- (void)moveUpViewForKeyboard:(CGSize)keyboardSize {
    [self layoutCommentViewWithHeight:keyboardSize.height];
}

- (void)resumeView {
    [self layoutCommentViewWithHeight:-50.0f];
}

- (void)layoutCommentViewWithHeight:(CGFloat)height {
//    __weak __typeof__(self)weakSelf = self;
//    _commentViewBottomConstraint.constant = height;
//    [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        __strong __typeof__(self)strongSelf = weakSelf;
//        [strongSelf.view layoutIfNeeded];
//    } completion:nil];
}

@end
