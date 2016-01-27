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
#import "MiaAPIHelper.h"
#import "HXAlertBanner.h"
#import "UserSession.h"
#import "FlyCommentItem.h"
#import "UIImageView+WebCache.h"

@interface HXRadioShareInfoView () <
TTTAttributedLabelDelegate
>
@end

@implementation HXRadioShareInfoView {
    __weak ShareItem *_item;
}

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
- (IBAction)sharerAvatarButtonPressed {
    if ([UserSession standard].state) {
        UserItem *shareUserItem = _item.shareUser;
        [MiaAPIHelper followWithUID:shareUserItem.uid isFollow:!shareUserItem.follow completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
            shareUserItem.follow = !shareUserItem.follow;
            [HXAlertBanner showWithMessage:(shareUserItem.follow ? @"添加关注成功" : @"取消关注成功") tap:nil];
            [self displayWithItem:_item];
        } timeoutBlock:^(MiaRequestItem *requestItem) {
            [HXAlertBanner showWithMessage:@"请求超时，请重试！" tap:nil];
        }];
    } else {
        if (_delegate && [_delegate respondsToSelector:@selector(radioShareInfoView:takeAction:)]) {
            [_delegate radioShareInfoView:self takeAction:HXRadioShareInfoActionAvatarTaped];
        }
    }
}

- (IBAction)contentTaped {
    if (_delegate && [_delegate respondsToSelector:@selector(radioShareInfoView:takeAction:)]) {
        [_delegate radioShareInfoView:self takeAction:HXRadioShareInfoActionContentTaped];
    }
}

#pragma mark - Public Methods
- (void)displayWithItem:(ShareItem *)item {
    _item = item;
    
    [_sharerAvatar sd_setImageWithURL:[NSURL URLWithString:item.shareUser.userpic] forState:UIControlStateNormal];
    _attentionIcon.image = [UIImage imageNamed:(item.shareUser.follow ? @"C-AttentionedIcon-Small": @"C-AttentionAddIcon-Small")];
    _timeLabel.text = item.formatTime;
    _shareContentLabel.text = [item.shareUser.nick stringByAppendingFormat:@"：%@", item.sNote];
    if ([item.shareUser.uid isEqualToString:item.spaceUser.uid]) {
        _sharerLabel.text = item.shareUser.nick ?: @"Unknown";
    } else {
        _sharerLabel.text = [item.spaceUser.nick stringByAppendingFormat:@" 秒推了 %@ 的分享", item.shareUser.nick];
    }
    [self displaySharerLabelWithSharer:item.shareUser.nick infecter:item.spaceUser.nick];
    [self displayFlyComments:item.flyComments];
}

#pragma mark - Private Methods
- (void)displayFlyComments:(NSArray <FlyCommentItem *> *)flyComments {
    BOOL hasComments = flyComments.count;
    _commentView.hidden = !hasComments;
    if (hasComments) {
//        _commentView.alpha = 0.0f;
//        [UIView animateWithDuration:1.2f animations:^{
//            _commentView.alpha = 1.0f;
//        }];
        FlyCommentItem *item = [flyComments lastObject];
        [_commentAvatar sd_setImageWithURL:[NSURL URLWithString:item.userpic]];
        _commentLabel.text = item.comment;
    }
}

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
    if ([phoneNumber isEqualToString:_item.shareUser.nick]) {
        if (_delegate && [_delegate respondsToSelector:@selector(radioShareInfoView:takeAction:)]) {
            [_delegate radioShareInfoView:self takeAction:HXRadioShareInfoActionSharerTaped];
        }
    } else if ([phoneNumber isEqualToString:_item.spaceUser.nick]) {
        if (_delegate && [_delegate respondsToSelector:@selector(radioShareInfoView:takeAction:)]) {
            [_delegate radioShareInfoView:self takeAction:HXRadioShareInfoActionInfecterTaped];
        }
    }
//    NSLog(@"Sharer Name Taped: %@", phoneNumber);
}



- (void)displayShareContentLabelWithContent:(NSString *)content locationInfo:(NSString *)locationInfo {
//    static NSInteger MaxLine = 3;
//    static NSString *HanWorld = @"肖";
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
