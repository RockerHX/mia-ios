//
//  HXCoverContainerCell.m
//  mia
//
//  Created by miaios on 16/1/28.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXCoverContainerCell.h"
#import "UIImageView+WebCache.h"

@implementation HXCoverContainerCell

#pragma mark - Public Methods
- (void)displayWithURL:(NSString *)url {
    [_cover sd_setImageWithURL:[NSURL URLWithString:url]];
}

@end
