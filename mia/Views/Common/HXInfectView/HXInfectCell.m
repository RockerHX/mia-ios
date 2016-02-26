//
//  HXInfectCell.m
//  mia
//
//  Created by miaios on 16/2/25.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXInfectCell.h"
#import "UIImageView+WebCache.h"

@implementation HXInfectCell

#pragma mark - Class Methods
+ (UINib *)nib {
    return [UINib nibWithNibName:NSStringFromClass([HXInfectCell class]) bundle:nil];
}

+ (NSString *)className {
    return NSStringFromClass([HXInfectCell class]);
}

#pragma mark - Load Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    _avatar.layer.drawsAsynchronously = YES;
}

- (void)viewConfigure {
    ;
}

#pragma mark - Public Methods
- (void)displayInfected:(BOOL)infected {
    _avatar.layer.cornerRadius = 0.0f;
    _avatar.layer.borderWidth = 0.0f;
    _avatar.image = [UIImage imageNamed:(infected ? @"D-InfectedIcon": @"D-InfectIcon")];
}

- (void)displayWithInfecter:(InfectUserItem *)infecter {
    _avatar.layer.cornerRadius = 16.0f;
    _avatar.layer.borderWidth = 1.0f;
    [_avatar sd_setImageWithURL:[NSURL URLWithString:infecter.avatar] placeholderImage:nil];
}

@end
