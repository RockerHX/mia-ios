//
//  HXInfectUserItemView.m
//  mia
//
//  Created by miaios on 15/10/20.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXInfectUserItemView.h"
#import "UIImageView+WebCache.h"

@implementation HXInfectUserItemView

#pragma mark - Class Methods
+ (instancetype)instance {
    HXInfectUserItemView *itemView = nil;
    @try {
        itemView = [[[NSBundle mainBundle] loadNibNamed:@"HXInfectUserItemView" owner:self options:nil] firstObject];
    }
    @catch (NSException *exception) {
        NSLog(@"HXInfectUserItemView Load From Nib Error:%@", exception.reason);
    }
    @finally {
        return itemView;
    }
}

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
    self.backgroundColor = [UIColor clearColor];
    
    _header.contentMode = UIViewContentModeScaleAspectFill;
    _header.layer.cornerRadius = _headerWidthContraint.constant/2;
    _header.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
    
    _whiteBorder.layer.cornerRadius = (_headerWidthContraint.constant*1.2)/2;
}

#pragma mark - Public Methods
- (void)reduce {
    _header.transform = CGAffineTransformIdentity;
}

- (void)displayWithURL:(NSURL *)url {
    [_header sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"HP-InfectUserDefaultHeader"]];
}

- (void)displayWithImageName:(NSString *)imageName {
    _header.image = [UIImage imageNamed:imageName];
}

@end
