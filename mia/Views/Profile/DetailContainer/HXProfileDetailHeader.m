//
//  HXProfileDetailHeader.m
//  mia
//
//  Created by miaios on 16/1/28.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXProfileDetailHeader.h"
#import "HXXib.h"

@implementation HXProfileDetailHeader

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


#pragma mark - Setter And Getter
- (void)setType:(HXProfileType)type {
    _type = type;
    _followButton.hidden = type;
}

#pragma mark - Event Response
- (IBAction)followButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(detailHeader:takeAction:)]) {
        [_delegate detailHeader:self takeAction:HXProfileDetailHeaderActionTakeFollow];
    }
}

#pragma mark - Public Methods

@end
