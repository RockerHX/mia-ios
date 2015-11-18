//
//  HXMusicDetailTopBar.m
//  mia
//
//  Created by miaios on 15/11/18.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXMusicDetailTopBar.h"
#import "UserSession.h"
#import "UIButton+WebCache.h"
#import "ShareItem.h"

@implementation HXMusicDetailTopBar

#pragma mark - Event Response
- (IBAction)backButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(topBarButtonPressed:)]) {
        [_delegate topBarButtonPressed:HXMusicDetailTopBarActionProfile];
    }
}

#pragma mark - Public Methods
- (void)updateMusicInfoWithItem:(nullable ShareItem *)item {
    _songNameLabel.text = item.music.name;
    _singerNameLabel.text = item.music.singerName;
}

@end
