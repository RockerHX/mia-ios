//
//  HXTopBar.m
//  mia
//
//  Created by miaios on 15/11/18.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXTopBar.h"
#import "UserSession.h"
#import "UIButton+WebCache.h"

@implementation HXTopBar

#pragma mark - Parent Methods
- (void)xibSetup {
    [super xibSetup];
    
    [self initConfig];
    [self viewConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
}

- (void)viewConfig {
    _shareButton.backgroundColor = [UIColor whiteColor];
    _profileButton.layer.borderWidth = 0.5f;
    _profileButton.layer.borderColor = UIColorFromHex(@"A2A2A2", 1.0f).CGColor;
    _profileButton.layer.cornerRadius = _profileButton.frame.size.height/2;
    
    _shareButton.backgroundColor = [UIColor whiteColor];
    _shareButton.layer.cornerRadius = _profileButton.frame.size.height/2;
}

#pragma mark - Event Response
- (IBAction)profileButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(topBarButtonPressed:)]) {
        [_delegate topBarButtonPressed:HXTopBarActionProfile];
    }
}

- (IBAction)shareButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(topBarButtonPressed:)]) {
        [_delegate topBarButtonPressed:HXTopBarActionShare];
    }
}

#pragma mark - Public Methods
- (void)updateProfileButtonImage:(UIImage *)image {
    [_profileButton setImage:image forState:UIControlStateNormal];
}

- (void)updateProfileButtonWithUnreadCount:(NSInteger)unreadCommentCount {
    if (unreadCommentCount <= 0) {
        _profileButton.layer.borderWidth = 0.5f;
        [_profileButton sd_setImageWithURL:[NSURL URLWithString:[[UserSession standard] avatar]]
                                  forState:UIControlStateNormal
                          placeholderImage:[UIImage imageNamed:@"HP-InfectUserDefaultHeader"]];
    } else {
        _profileButton.layer.borderWidth = 0.0f;
        [_profileButton setImage:nil forState:UIControlStateNormal];
        [_profileButton setBackgroundColor:UIColorFromHex(@"0BDEBC", 1.0)];
        [_profileButton setTitle:[NSString stringWithFormat:@"%zd", unreadCommentCount] forState:UIControlStateNormal];
    }
}

@end
