//
//  HXRadioShareInfoView.m
//  mia
//
//  Created by miaios on 16/1/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXRadioShareInfoView.h"
#import "HXXib.h"
#import "TTTAttributedLabel.h"

@interface HXRadioShareInfoView () <
TTTAttributedLabelDelegate
>
@end

@implementation HXRadioShareInfoView

HXXibImplementation

#pragma mark - Load Methods
- (void)awakeFromNib {
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    [self displaySharerLabelWithSharer:@"王晶" infecter:@"冰心"];
}

- (void)viewConfigure {
    ;
}

#pragma mark - Event Response
- (void)sharerAvatarButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(radioShareInfoView:takeAction:)]) {
        [_delegate radioShareInfoView:self takeAction:HXRadioShareInfoActionAvatarTaped];
    }
}

#pragma mark - Private Methods
- (void)displaySharerLabelWithSharer:(NSString *)sharer infecter:(NSString *)infecter {
    NSDictionary *linkAttributes = @{(__bridge id)kCTUnderlineStyleAttributeName: [NSNumber numberWithInt:kCTUnderlineStyleNone],
                                    (__bridge id)kCTForegroundColorAttributeName: [UIColor blackColor],
                                               (__bridge id)kCTFontAttributeName: [UIFont boldSystemFontOfSize:_sharerLabel.font.pointSize]};
    _sharerLabel.activeLinkAttributes = linkAttributes;
    _sharerLabel.linkAttributes = linkAttributes;
    [_sharerLabel addLinkToPhoneNumber:sharer withRange:[_sharerLabel.text rangeOfString:sharer]];
    [_sharerLabel addLinkToPhoneNumber:infecter withRange:[_sharerLabel.text rangeOfString:infecter]];
}

#pragma mark - TTTAttributedLabelDelegate Methods
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    NSLog(@"Sharer Name Taped: %@", phoneNumber);
}

@end
