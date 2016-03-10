//
//  HXPlayTopBar.m
//  mia
//
//  Created by miaios on 16/2/25.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXPlayTopBar.h"
#import "HXXib.h"

@implementation HXPlayTopBar

HXXibImplementation

#pragma mark - Load Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    ;
}

- (void)viewConfigure {
    _containerView.backgroundColor = [UIColor clearColor];
}

- (IBAction)sharerTapGesture {
    if (_delegate && [_delegate respondsToSelector:@selector(topBar:takeAction:)]) {
        [_delegate topBar:self takeAction:HXPlayTopBarActionSharerTaped];
    }
}

#pragma mark - Event Response
- (IBAction)backButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(topBar:takeAction:)]) {
        [_delegate topBar:self takeAction:HXPlayTopBarActionBack];
    }
}

- (IBAction)listButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(topBar:takeAction:)]) {
        [_delegate topBar:self takeAction:HXPlayTopBarActionShowList];
    }
}

@end
