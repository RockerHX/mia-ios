//
//  HXInfectListCell.m
//  mia
//
//  Created by miaios on 15/10/22.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXInfectListCell.h"
#import "UIImageView+WebCache.h"
#import "HXVersion.h"

@implementation HXInfectListCell

#pragma mark - Init Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initConfig];
    [self viewConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
    ;
}

- (void)viewConfig {
    _header.layer.cornerRadius = _header.frame.size.height/2;
    
    if ([HXVersion currentModel] == SCDeviceModelTypeIphone5_5S) {
        _labelSpaceConstraint.constant = 2.0f;
        _header.layer.cornerRadius = _header.frame.size.height/2 - 5.0f;
        _nameLabel.font = [UIFont systemFontOfSize:14.0f];
        _dynamicLabel.font = [UIFont systemFontOfSize:13.0f];
    }
}

#pragma mark - Public Methods
- (void)displayWithItem:(InfectItem *)item {
    [_header sd_setImageWithURL:[NSURL URLWithString:item.avatar] placeholderImage:[UIImage imageNamed:@"C-AvatarDefaultIcon"] options:SDWebImageRetryFailed];
    _nameLabel.text = item.nick;
    _dynamicLabel.text = [NSString stringWithFormat:@"最近分享:%@", item.lastShare];
}

@end
