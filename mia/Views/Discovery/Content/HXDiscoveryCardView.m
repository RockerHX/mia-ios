//
//  HXDiscoveryCardView.m
//  mia
//
//  Created by miaios on 16/2/18.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXDiscoveryCardView.h"
#import "HXXib.h"
#import "HXDiscoveryCover.h"
#import "ShareItem.h"

@implementation HXDiscoveryCardView

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
    ;
}

#pragma mark - Public Methods
- (void)displayWithItem:(id)item {
    if ([item isKindOfClass:[ShareItem class]]) {
        ShareItem *shareItem = item;
        [_coverView displayWithItem:shareItem];
    }
}

@end
