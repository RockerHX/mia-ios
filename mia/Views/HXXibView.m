//
//  HXXibView.m
//  mia
//
//  Created by miaios on 15/11/17.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXXibView.h"

@implementation HXXibView

#pragma mark - Init Methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self xibSetup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self xibSetup];
    }
    return self;
}

#pragma mark - Private Methods
- (void)xibSetup {
    UIView *view = [self loadViewFromNib];
    view.frame = self.bounds;
    [self addSubview:view];
}

- (UIView *)loadViewFromNib {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:bundle];
    UIView *view = [[nib instantiateWithOwner:self options:nil] firstObject];
    return view;
}

@end
