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
    _shareInfoLabel.text = [NSString stringWithFormat:@"%@：%@", item.sNick, item.sNote];
    [self displayShareContentLabelWithSharerName:item.sNick];
}

#pragma mark - Private Methods
- (void)displayShareContentLabelWithSharerName:(NSString *)sharerName {
    NSRange range = [_shareInfoLabel.text rangeOfString:(sharerName ?: @"")];
    [_shareInfoLabel addLinkToURL:[NSURL URLWithString:@""] withRange:range];
}


#pragma mark - TTTAttributedLabelDelegate Methods
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if (_delegate && [_delegate respondsToSelector:@selector(cellUserWouldLikeSeeSharerInfo:)]) {
        [_delegate cellUserWouldLikeSeeSharerInfo:self];
    }
}

@end
