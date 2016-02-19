//
//  HXDiscoveryCell.m
//  mia
//
//  Created by miaios on 16/2/18.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXDiscoveryCell.h"

@implementation HXDiscoveryCell

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
    self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.layer.shadowRadius = 4.0f;
    self.layer.shadowOpacity = 1.0f;
}

@end
