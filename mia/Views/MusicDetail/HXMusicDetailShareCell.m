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
    _shareInfoLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 95.0f;
    _shareInfoLabel.delegate = self;
}

#pragma mark - Public Methods
- (void)displayWithShareItem:(ShareItem *)item {
    [self displayShareContentLabelWithSharerName:[item.sNick stringByAppendingString:@"："] note:item.sNote];
}

#pragma mark - Private Methods
- (void)displayShareContentLabelWithSharerName:(NSString *)sharerName note:(NSString *)note {
    _shareInfoLabel.text = [sharerName stringByAppendingString:note];
    NSDictionary *linkAttributes = @{(__bridge id)kCTUnderlineStyleAttributeName: [NSNumber numberWithInt:kCTUnderlineStyleNone],
                                     (__bridge id)kCTForegroundColorAttributeName: [UIColor blackColor]};
    _shareInfoLabel.activeLinkAttributes = linkAttributes;
    _shareInfoLabel.linkAttributes = linkAttributes;
    [_shareInfoLabel addLinkToPhoneNumber:sharerName withRange:[_shareInfoLabel.text rangeOfString:sharerName]];
}

#pragma mark - TTTAttributedLabelDelegate Methods
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    if (_delegate && [_delegate respondsToSelector:@selector(cellUserWouldLikeSeeSharerInfo:)]) {
        [_delegate cellUserWouldLikeSeeSharerInfo:self];
    }
}

@end
