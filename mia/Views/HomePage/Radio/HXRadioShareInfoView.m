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
    __weak UserItem *_avatarItem;
    
    NSTimer *_timer;
    NSInteger _loop;
}

HXXibImplementation

#pragma mark - Load Methods
- (void)awakeFromNib {
    [self loadConfigure];
    [self viewConfigure];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
	[self displayWithItem:_item];
}

- (void)dealloc {
	[_timer invalidate];
	[_item removeObserver:self forKeyPath:@"flyComments"];
    [_item.shareUser removeObserver:self forKeyPath:@"follow"];
    [_item.spaceUser removeObserver:self forKeyPath:@"follow"];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    _shareContentLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 50.0f;
}

- (void)viewConfigure {
    ;
}

#pragma mark - Event Response
- (IBAction)sharerAvatarTaped {
    if ([UserSession standard].state) {
        if (![_avatarItem.uid isEqual:[UserSession standard].uid]) {
            [MiaAPIHelper followWithUID:_avatarItem.uid isFollow:!_avatarItem.follow completeBlock:^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
                _avatarItem.follow = !_avatarItem.follow;
                [HXAlertBanner showWithMessage:(_avatarItem.follow ? @"添加关注成功" : @"取消关注成功") tap:nil];
                [self displayWithItem:_item];
            } timeoutBlock:^(MiaRequestItem *requestItem) {
                [HXAlertBanner showWithMessage:@"请求超时，请重试！" tap:nil];
            }];
        }
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
    [self configureItem:item];
    
    UserItem *shareUser = item.shareUser;
    UserItem *spaceUser = item.spaceUser;
    if ([shareUser.uid isEqualToString:spaceUser.uid]) {
        _avatarItem = shareUser;
        _sharerLabel.text = shareUser.nick ?: @"Unknown";
    } else {
        _avatarItem = spaceUser;
        _sharerLabel.text = [spaceUser.nick stringByAppendingFormat:@" 妙推了 %@ 的分享", shareUser.nick];
    }
    
    _timeLabel.text = item.formatTime;
    _shareContentLabel.text = [shareUser.nick stringByAppendingFormat:@"：%@", item.sNote];
    [_sharerAvatar sd_setImageWithURL:[NSURL URLWithString:_avatarItem.userpic] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    _attentionIcon.hidden = [_avatarItem.uid isEqualToString:[UserSession standard].uid];
    _attentionIcon.image = [UIImage imageNamed:(_avatarItem.follow ? @"C-AttentionedIcon-Small": @"C-AttentionAddIcon-Small")];
    [self displaySharerLabelWithSharer:shareUser.nick infecter:spaceUser.nick];
    [self displayFlyComments:item.flyComments];

	// 兼容0.3版本升级上来的用户，老的卡片数据，分享者这几个元素直接隐藏
	[_sharerView setHidden:(nil == shareUser)];
}

#pragma mark - Private Methods
- (void)configureItem:(ShareItem *)item {
    [_item removeObserver:self forKeyPath:@"flyComments"];
    [_item.shareUser removeObserver:self forKeyPath:@"follow"];
    [_item.spaceUser removeObserver:self forKeyPath:@"follow"];
	_item = item;
    [item addObserver:self forKeyPath:@"flyComments" options:NSKeyValueObservingOptionNew context:nil];
    [item.shareUser addObserver:self forKeyPath:@"follow" options:NSKeyValueObservingOptionNew context:nil];
    [item.spaceUser addObserver:self forKeyPath:@"follow" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)displayFlyComments:(NSArray <FlyCommentItem *> *)flyComments {
    BOOL hasComments = flyComments.count;
    _commentView.hidden = !hasComments;
    if (hasComments) {
        [self displayFlyComment:[flyComments firstObject]];
        
        _commentView.alpha = 0.0f;
        [UIView animateWithDuration:0.3f animations:^{
            _commentView.alpha = 1.0f;
        } completion:^(BOOL finished) {
			// 只有一条没必要切换
			if (flyComments.count > 1) {
				[self starScrollFlyComments];
			}
        }];
    }
}

- (void)starScrollFlyComments {
    _loop = 0;
    [_timer invalidate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(scrollFlyCommentsAnimation) userInfo:nil repeats:YES];
}

- (void)scrollFlyCommentsAnimation {
    NSArray <FlyCommentItem *> *flyComments = _item.flyComments;
    if (_loop < flyComments.count - 1) {
        _loop++;
    } else {
        _loop = 0;
    }
    
    _commentView.alpha = 1.0f;
    [UIView animateWithDuration:0.4 delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        _commentView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self displayFlyComment:flyComments[_loop]];
        _commentView.alpha = 0.0f;
        [UIView animateWithDuration:0.4 delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            _commentView.alpha = 1.0f;
        } completion:nil];
    }];
}

- (void)displayFlyComment:(FlyCommentItem *)commentItem {
    [_commentAvatar sd_setImageWithURL:[NSURL URLWithString:commentItem.userpic] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    _commentLabel.text = commentItem.comment;
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
