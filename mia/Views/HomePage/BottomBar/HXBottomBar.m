//
//  HXBottomBar.m
//  mia
//
//  Created by miaios on 15/11/17.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXBottomBar.h"

@implementation HXBottomBar

#pragma mark - Event Response
- (IBAction)feedBackButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(bottomBarButtonPressed:)]) {
        [_delegate bottomBarButtonPressed:HXBottomBarButtonTypeFeedBack];
    }
}

- (IBAction)commentButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(bottomBarButtonPressed:)]) {
        [_delegate bottomBarButtonPressed:HXBottomBarButtonTypeComment];
    }
}

- (IBAction)favoriteButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(bottomBarButtonPressed:)]) {
        [_delegate bottomBarButtonPressed:HXBottomBarButtonTypeFavorite];
    }
}

- (IBAction)moreButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(bottomBarButtonPressed:)]) {
        [_delegate bottomBarButtonPressed:HXBottomBarButtonTypeMore];
    }
}

@end
