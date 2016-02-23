//
//  HXNavigationBar.m
//  mia
//
//  Created by miaios on 16/1/27.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXNavigationBar.h"
#import "HXXib.h"
#import "UIView+FindUIViewController.h"

@interface HXNavigationBar ()

@property (weak, nonatomic) IBOutlet  UIView *backgroundView;
@property (weak, nonatomic) IBOutlet  UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation HXNavigationBar

HXXibImplementation

#pragma mark - Setter And Getter
- (void)setColorAlpha:(CGFloat)colorAlpha {
    _colorAlpha = colorAlpha;
    
    _backgroundView.alpha = colorAlpha;
    _titleLabel.alpha = colorAlpha;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    _titleLabel.text = title;
}

#pragma mark - Event Response
- (IBAction)backButtonPressed {
    UIViewController *firstAvailableViewController = [self firstAvailableViewController];
    [firstAvailableViewController.navigationController popViewControllerAnimated:YES];

	if (_delegate && [_delegate respondsToSelector:@selector(navigationBarDidBackAction)]) {
		[_delegate navigationBarDidBackAction];
	}

}

@end
