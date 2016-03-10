//
//  HXDiscoveryPlaceHolderCardView.m
//  mia
//
//  Created by miaios on 16/3/9.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXDiscoveryPlaceHolderCardView.h"
#import "HXXib.h"


@implementation HXDiscoveryPlaceHolderCardView

HXXibImplementation

#pragma mark - Event Response
- (IBAction)refreshButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(placeHolderCardView:takeAction:)]) {
        [_delegate placeHolderCardView:self takeAction:HXDiscoveryPlaceHolderCardViewActionRefresh];
    }
}

@end
