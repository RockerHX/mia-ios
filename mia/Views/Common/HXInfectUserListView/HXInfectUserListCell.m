//
//  HXInfectUserListCell.m
//  mia
//
//  Created by miaios on 15/10/22.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXInfectUserListCell.h"
#import "UIImageView+WebCache.h"

@implementation HXInfectUserListCell

#pragma mark - Init Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initConfig];
    [self viewConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
    
}

- (void)viewConfig {
    _header.layer.cornerRadius = _header.frame.size.height/2;
}

#pragma mark - Public Methods
- (void)displayWithItem:(id)item {
    
    [_header sd_setImageWithURL:[NSURL URLWithString:@""]];
    _nameLabel.text = @"";
    _dynamicLabel.text = @"";
}

@end
