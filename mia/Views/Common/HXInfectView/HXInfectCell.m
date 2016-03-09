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
- (void)displayWithInfecter:(InfectUserItem *)infecter {
    [_avatar sd_setImageWithURL:[NSURL URLWithString:infecter.avatar] placeholderImage:[UIImage imageNamed:@"C-AvatarDefaultIcon"]];
}

@end
