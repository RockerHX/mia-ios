//
//  HXXib.h
//
//  Created by miaios on 15/11/17.
//  Copyright © 2015年 miaios. All rights reserved.
//

#define HXXibImplementation \
- (instancetype)initWithFrame:(CGRect)frame { \
    self = [super initWithFrame:frame]; \
    if (self) { \
        [self xibSetup]; \
    } \
    return self; \
} \
\
- (instancetype)initWithCoder:(NSCoder *)aDecoder { \
    self = [super initWithCoder:aDecoder]; \
    if (self) { \
        [self xibSetup]; \
    } \
    return self; \
} \
\
- (void)xibSetup { \
    UIView *view = [self loadViewFromNib]; \
    view.frame = self.bounds; \
    [self addSubview:view]; \
} \
\
- (UIView *)loadViewFromNib { \
    NSBundle *bundle = [NSBundle bundleForClass:[self class]]; \
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:bundle]; \
    UIView *view = [[nib instantiateWithOwner:self options:nil] firstObject]; \
    return view; \
} \
