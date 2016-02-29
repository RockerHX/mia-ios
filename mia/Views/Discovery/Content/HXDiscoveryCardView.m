//
//  HXDiscoveryCardView.m
//  mia
//
//  Created by miaios on 16/2/18.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXDiscoveryCardView.h"
#import "HXXib.h"
#import "ShareItem.h"
#import "HXDiscoveryCover.h"
#import "TTTAttributedLabel.h"
#import "HXInfectView.h"
#import "UIConstants.h"

@interface HXDiscoveryCardView () <
HXDiscoveryCoverDelegate,
TTTAttributedLabelDelegate,
HXInfectViewDelegate
>
@end

@implementation HXDiscoveryCardView {
    CAShapeLayer *_sharerNickNameLayer;
}

HXXibImplementation

#pragma mark - Load Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    _sharerLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 30.0f;
}

- (void)viewConfigure {
    ;
}

#pragma mark - Event Response
- (IBAction)favoriteAction {
    if (_delegate && [_delegate respondsToSelector:@selector(cardView:takeAction:)]) {
        [_delegate cardView:self takeAction:HXDiscoveryCardViewActionFavorite];
    }
}

- (IBAction)showCommenterAction {
    if (_delegate && [_delegate respondsToSelector:@selector(cardView:takeAction:)]) {
        [_delegate cardView:self takeAction:HXDiscoveryCardViewActionShowCommenter];
    }
}

- (IBAction)showCommentAction {
    if (_delegate && [_delegate respondsToSelector:@selector(cardView:takeAction:)]) {
        [_delegate cardView:self takeAction:HXDiscoveryCardViewActionComment];
    }
}

- (IBAction)showDetailAction {
    if (_delegate && [_delegate respondsToSelector:@selector(cardView:takeAction:)]) {
        [_delegate cardView:self takeAction:HXDiscoveryCardViewActionShowDetail];
    }
}

#pragma mark - Public Methods
- (void)displayWithItem:(id)item {
    if ([item isKindOfClass:[ShareItem class]]) {
        ShareItem *shareItem = item;
        [_coverView displayWithItem:shareItem];
        [self displaySharerLabelWithSharer:shareItem.sNick content:shareItem.sNote];
        [_infectView setInfecters:shareItem.infectUsers];
        
//        _commentatorsNameLabel.text = shareItem.flyComments.firstObject.comment;
        _commentContentLabel.text = shareItem.lastComment.comment;
    }
}

#pragma mark - Private Methods
- (void)displaySharerLabelWithSharer:(NSString *)sharer content:(NSString *)content {
    NSString *sharerString = [NSString stringWithFormat:@"  %@  ", sharer];
    NSString *shareContent = [NSString stringWithFormat:@"%@  %@", sharerString, content];
    _sharerLabel.text = shareContent;
    
    // 文字背景Layer
    if (!_sharerNickNameLayer) {
        _sharerNickNameLayer = [CAShapeLayer layer];
        _sharerNickNameLayer.fillColor = UIColorByHex(0xEBEFF0).CGColor;
        _sharerNickNameLayer.strokeColor = _sharerNickNameLayer.fillColor;
        [_sharerLabel.layer insertSublayer:_sharerNickNameLayer atIndex:0];
    }
    
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f]};
    CGRect rect = [sharerString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 20.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0.0f, -1.0f, rect.size.width, 20.0f) cornerRadius:10.0f];
    _sharerNickNameLayer.path = path.CGPath;
    
    // 文字渲染
    NSDictionary *linkAttributes = @{(__bridge id)kCTUnderlineStyleAttributeName: [NSNumber numberWithInt:kCTUnderlineStyleNone],
                                     (__bridge id)kCTForegroundColorAttributeName: [UIColor blackColor],
                                     (__bridge id)kCTFontAttributeName: [UIFont systemFontOfSize:14.0f]};
    _sharerLabel.activeLinkAttributes = linkAttributes;
    _sharerLabel.linkAttributes = linkAttributes;
    [_sharerLabel addLinkToPhoneNumber:sharer withRange:[shareContent rangeOfString:sharer]];
}

#pragma mark - HXDiscoveryCoverDelegate Methods
- (void)cover:(HXDiscoveryCover *)cover takeAcion:(HXDiscoveryCoverAction)action {
    HXDiscoveryCardViewAction cardAction = HXDiscoveryCardViewActionPlay;
    switch (action) {
        case HXDiscoveryCoverActionPlay: {
            break;
        }
        case HXDiscoveryCoverActionShowSharer: {
            cardAction = HXDiscoveryCardViewActionShowSharer;
            break;
        }
        case HXDiscoveryCoverActionShowInfecter: {
            cardAction = HXDiscoveryCardViewActionShowInfecter;
            break;
        }
    }
    if (_delegate && [_delegate respondsToSelector:@selector(cardView:takeAction:)]) {
        [_delegate cardView:self takeAction:cardAction];
    }
}

#pragma mark - TTTAttributedLabelDelegate Methdos
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    if (_delegate && [_delegate respondsToSelector:@selector(cardView:takeAction:)]) {
        [_delegate cardView:self takeAction:HXDiscoveryCardViewActionShowSharer];
    }
}

#pragma mark - HXInfectViewDelegate Methods
- (void)infectView:(HXInfectView *)infectView takeAction:(HXInfectViewAction)action {
    switch (action) {
        case HXInfectViewActionInfect: {
            if (_delegate && [_delegate respondsToSelector:@selector(cardView:takeAction:)]) {
                [_delegate cardView:self takeAction:HXDiscoveryCardViewActionInfect];
            }
            break;
        }
    }
}

- (void)infectViewInfecterTaped:(HXInfectView *)infectView atIndex:(NSInteger)index {
    [self showDetailAction];
}

@end
