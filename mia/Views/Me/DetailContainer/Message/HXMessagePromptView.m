//
//  HXMessagePromptView.m
//  mia
//
//  Created by miaios on 16/3/4.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXMessagePromptView.h"
#import "HXXib.h"
#import "UIImageView+WebCache.h"


@implementation HXMessagePromptView

HXXibImplementation

#pragma mark - Event Response
- (IBAction)tapGesture {
    if (_delegate && [_delegate respondsToSelector:@selector(messagePromptViewTaped:)]) {
        [_delegate messagePromptViewTaped:self];
    }
}

#pragma mark - Public Methods
- (void)displayWithAvatarURL:(NSString *)url promptCount:(NSInteger)count {
    [_avatar sd_setImageWithURL:[NSURL URLWithString:url]];
    _promptLabel.text = [@(count).stringValue stringByAppendingString:@"条新消息"];
}

@end
