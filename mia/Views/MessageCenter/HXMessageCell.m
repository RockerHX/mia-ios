//
//  HXMessageCell.m
//  mia
//
//  Created by miaios on 16/1/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXMessageCell.h"
#import "TTTAttributedLabel.h"
#import "MessageItem.h"
#import "UIButton+WebCache.h"

@implementation HXMessageCell

#pragma mark - Load Methods
- (void)awakeFromNib {
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    _descriptionLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 92.0f;
    _contentLabel.preferredMaxLayoutWidth = _descriptionLabel.preferredMaxLayoutWidth;
}

- (void)viewConfigure {
    ;
}

#pragma mark - Event Response
- (IBAction)avatarButtonPressed {
    if (_delegate && [_delegate respondsToSelector:@selector(messageCell:takeAction:)]) {
        [_delegate messageCell:self takeAction:HXMessageCellActionAvatarTaped];
    }
}

#pragma mark - Public Methods
- (void)displayWithMessageItem:(MessageItem *)item {
    [_avatarButton sd_setImageWithURL:[NSURL URLWithString:item.fromUserpic] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    _messageIcon.hidden = item.hasReaded;
    _descriptionLabel.text = [item.fromUserName stringByAppendingFormat:@" %@", item.title];
    _contentLabel.text = item.content;
    _timeLabel.text = item.formatTime;
    
    [self displayDescriptionLabelWithSharer:item.fromUserName];
}

#pragma mark - Private Methods
- (void)displayDescriptionLabelWithSharer:(NSString *)sharer {
    NSDictionary *linkAttributes = @{(__bridge id)kCTForegroundColorAttributeName: [UIColor blackColor],
                                                (__bridge id)kCTFontAttributeName: [UIFont boldSystemFontOfSize:_descriptionLabel.font.pointSize]};
    NSString *text = _descriptionLabel.text;
    [_descriptionLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange boldRange = [text rangeOfString:sharer];
        if (sharer.length) {
            [mutableAttributedString addAttributes:linkAttributes range:boldRange];
        }
        return mutableAttributedString;
    }];
}

@end
