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
#import "ShareItem.h"
#import "UIButton+WebCache.h"

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
    _shareContentLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 50.0f;
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

#pragma mark - Public Methods
- (void)displayWithItem:(ShareItem *)item {
    [_sharerAvatar sd_setImageWithURL:[NSURL URLWithString:item.shareUser.userpic] forState:UIControlStateNormal];
    _attentionIcon.image = [UIImage imageNamed:(item.shareUser.follow ? @"C-AttentionedIcon-Small": @"C-AttentionAddIcon-Small")];
    _shareContentLabel.text = [item.shareUser.nick stringByAppendingFormat:@"：%@", item.sNote];
    if ([item.shareUser.uid isEqualToString:item.spaceUser.uid]) {
        _sharerLabel.text = item.shareUser.nick;
    } else {
        _sharerLabel.text = [item.spaceUser.nick stringByAppendingFormat:@" 秒推了 %@ 的分享", item.shareUser.nick];
    }
    [self displaySharerLabelWithSharer:item.shareUser.nick infecter:item.spaceUser.nick];
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



static NSInteger MaxLine = 3;
static NSString *HanWorld = @"肖";
- (void)displayShareContentLabelWithContent:(NSString *)content locationInfo:(NSString *)locationInfo {
    //    NSString *text = [NSString stringWithFormat:@"%@%@", (content.length ? [NSString stringWithFormat:@"“%@”  ", content] : @""), (locationInfo ?: @"")];
    //
    //    CGFloat labelWidth = _shrareContentLabel.preferredMaxLayoutWidth;
    //    CGSize maxSize = CGSizeMake(labelWidth, MAXFLOAT);
    //    UIFont *labelFont = _shrareContentLabel.font;
    //    CGFloat textHeight = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:labelFont} context:nil].size.height;
    //    CGFloat lineHeight = [@" " boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:labelFont} context:nil].size.height;
    //    CGFloat threeLineHeightThreshold = lineHeight*3;
    //    if (textHeight > lineHeight) {
    //        _shrareContentLabel.textAlignment = NSTextAlignmentLeft;
    //
    //        if (textHeight > threeLineHeightThreshold) {
    //            CGFloat maxWidth = labelWidth*MaxLine;
    //            CGSize locationMaxSize = CGSizeMake(MAXFLOAT, lineHeight);
    //            NSString *coutText = [NSString stringWithFormat:@"...”  %@", locationInfo];
    //            CGFloat worldWith = [HanWorld boundingRectWithSize:locationMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:labelFont} context:nil].size.width;
    //            CGFloat locationInfoWidth = [coutText boundingRectWithSize:locationMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_shrareContentLabel.font} context:nil].size.width;
    //            CGFloat commentSurplusWidth = maxWidth - locationInfoWidth;
    //            NSInteger commentWorldCount = (commentSurplusWidth/worldWith) + 1;
    //            text = [NSString stringWithFormat:@"%@%@", [text substringWithRange:(NSRange){0, commentWorldCount}], coutText];
    //        }
    //    } else {
    //        _shrareContentLabel.textAlignment = NSTextAlignmentCenter;
    //    }
    //
    //
    //    [_shrareContentLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
    //        NSRange boldRange = [[mutableAttributedString string] rangeOfString:locationInfo options:NSCaseInsensitiveSearch];
    //        [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)[UIColor lightGrayColor].CGColor range:boldRange];
    //        return mutableAttributedString;
    //    }];
}

@end
