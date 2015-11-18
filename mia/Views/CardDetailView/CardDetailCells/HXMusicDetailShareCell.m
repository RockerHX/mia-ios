//
//  HXMusicDetailShareCell.m
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXMusicDetailShareCell.h"
#import "TTTAttributedLabel.h"
#import "ShareItem.h"

@interface HXMusicDetailShareCell () <TTTAttributedLabelDelegate>

@end

@implementation HXMusicDetailShareCell

#pragma mark - Init Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
    _shareReasonLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 95.0f;
    _shareReasonLabel.delegate = self;
}

#pragma mark - Public Methods
- (void)displayWithShareItem:(nullable ShareItem *)item {
    [self displayShareContentLabelWithSharerName:[item.sNick stringByAppendingString:@"："] note:item.sNote];
}

#pragma mark - Private Methods
- (void)displayShareContentLabelWithSharerName:(NSString *)sharerName note:(NSString *)note {
    NSString *text = [NSString stringWithFormat:@"%@%@", sharerName, note];
    CGFloat labelWidth = _shareReasonLabel.frame.size.width;
    CGSize maxSize = CGSizeMake(labelWidth, MAXFLOAT);
    UIFont *labelFont = _shareReasonLabel.font;
    CGFloat textHeight = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:labelFont} context:nil].size.height;
    CGFloat lineHeight = [@" " boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:labelFont} context:nil].size.height;
    if (textHeight > lineHeight) {
        _shareReasonLabel.textAlignment = NSTextAlignmentLeft;
    } else {
        _shareReasonLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    _shareReasonLabel.text = text;
    NSRange range = [_shareReasonLabel.text rangeOfString:(sharerName ?: @"")];
    [_shareReasonLabel addLinkToURL:[NSURL URLWithString:@""] withRange:range];
    NSMutableDictionary *linkAttributes = _shareReasonLabel.linkAttributes.mutableCopy;
    [linkAttributes setValue:@(0) forKey:@"NSUnderline"];
    [linkAttributes setValue:UIColorFromHex(@"4383e9", 1.0f) forKey:@"CTForegroundColor"];
    _shareReasonLabel.linkAttributes = linkAttributes;
    NSMutableDictionary *activeLinkAttributes = _shareReasonLabel.activeLinkAttributes.mutableCopy;
    [activeLinkAttributes setValue:UIColorFromHex(@"4383e9", 1.0f) forKey:@"CTForegroundColor"];
    _shareReasonLabel.activeLinkAttributes = activeLinkAttributes;
}


#pragma mark - TTTAttributedLabelDelegate Methods
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if (_delegate && [_delegate respondsToSelector:@selector(cellUserWouldLikeSeeSharerInfo:)]) {
        [_delegate cellUserWouldLikeSeeSharerInfo:self];
    }
}

@end
