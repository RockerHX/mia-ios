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
        [_delegate bottomBarButtonPressed:HXBottomBarActionFeedBack];
    }
}

- (IBAction)commentButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(bottomBarButtonPressed:)]) {
        [_delegate bottomBarButtonPressed:HXBottomBarActionComment];
    }
}

- (IBAction)favoriteButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(bottomBarButtonPressed:)]) {
        [_delegate bottomBarButtonPressed:HXBottomBarActionFavorite];
    }
}

- (IBAction)moreButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(bottomBarButtonPressed:)]) {
        [_delegate bottomBarButtonPressed:HXBottomBarActionMore];
    }
}

#pragma mark - Public Methods
- (void)updateFavoriteStateWithFavorite:(BOOL)favorite {
    if (favorite) {
        [_favoriteButton setImage:[UIImage imageNamed:@"MD-StarIcon"] forState:UIControlStateNormal];
    } else {
        [_favoriteButton setImage:[UIImage imageNamed:@"MD-UnStarIcon"] forState:UIControlStateNormal];
    }
}

@end
