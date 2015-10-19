//
//  HXNoNetworkView.m
//  mia
//
//  Created by miaios on 15/10/19.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXNoNetworkView.h"

typedef void(^BLOCK)(void);

@interface HXNoNetworkView () {
    BLOCK _showBlock;
    BLOCK _playBlock;
}

@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end

@implementation HXNoNetworkView

#pragma mark - Class Methods
+ (instancetype)showOnViewController:(UIViewController *)viewController show:(void(^)(void))showBlock play:(void(^)(void))playBlock {
    HXNoNetworkView *view = [[[NSBundle mainBundle] loadNibNamed:@"HXNoNetworkView" owner:self options:nil] firstObject];
    [view showOnViewController:viewController show:showBlock play:playBlock];
    return view;
}

#pragma mark - Init Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self viewConfig];
}

#pragma mark - Config Methods
- (void)viewConfig {
    _playButton.layer.cornerRadius = _playButton.frame.size.height/2;
}

#pragma mark - Event Response
- (IBAction)userHeaderButtonPressed {
    [self removeFromSuperview];
    if (_showBlock) {
        _showBlock();
    }
}

- (IBAction)playButtonPressed {
    [self removeFromSuperview];
    if (_playBlock) {
        _playBlock();
    }
}

#pragma mark - Public Methods
- (void)showOnViewController:(UIViewController *)viewController show:(void(^)(void))showBlock play:(void(^)(void))playBlock {
    _showBlock = showBlock;
    _playBlock = playBlock;
    self.frame = viewController.navigationController.view.frame;
    [viewController.view addSubview:self];
    [viewController.navigationController popToRootViewControllerAnimated:NO];
}

@end
