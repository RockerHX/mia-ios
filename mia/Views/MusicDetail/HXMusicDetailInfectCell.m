//
//  HXMusicDetailInfectCell.m
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXMusicDetailInfectCell.h"
#import "HXMusicDetailViewModel.h"
#import "TTTAttributedLabel.h"
#import "HXInfectUserView.h"
#import "InfectUserItem.h"

@implementation HXMusicDetailInfectCell

#pragma mark - Init Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(infectUsersTaped)];
    [_infectPromptLabel addGestureRecognizer:tapGesture];
}

#pragma mark - Public Methods
- (void)displayWithViewModel:(HXMusicDetailViewModel *)viewModel {
    ShareItem *item = viewModel.playItem;
    [self showInfectUsers:viewModel.playItem.infectUsers];
    [self displayPromptLabelWithCount:@(item.infectTotal).stringValue prompt:@"人妙推"];
}

#pragma mark - Event Response
- (void)infectUsersTaped {
    if (_delegate && [_delegate respondsToSelector:@selector(cellUserWouldLikeShowInfectList:)]) {
        [_delegate cellUserWouldLikeShowInfectList:self];
    }
}

#pragma mark - Private Methods
- (void)showInfectUsers:(NSArray *)infectUsers {
    [_infectUserView removeAllItem];
    if (infectUsers) {
        NSMutableArray *itmes = [NSMutableArray arrayWithCapacity:infectUsers.count];
        for (InfectUserItem *item in infectUsers) {
            [itmes addObject:[NSURL URLWithString:item.avatar]];
        }
        [_infectUserView showWithItems:itmes];
        __weak __typeof__(self)weakSelf = self;
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            __strong __typeof__(self)strongSelf = weakSelf;
            [strongSelf.infectUserView refresh];
        } completion:^(BOOL finished) {
            __strong __typeof__(self)strongSelf = weakSelf;
            // 妙推用户头像跳动动画
            [strongSelf.infectUserView refreshItemWithAnimation];
        }];
    }
}

- (void)displayPromptLabelWithCount:(NSString *)count prompt:(NSString *)prompt {
    NSString *text = [NSString stringWithFormat:@"%@%@", (count.length ? count : @""), (prompt ?: @"")];
    
    [_infectPromptLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange boldRange = [[mutableAttributedString string] rangeOfString:prompt options:NSCaseInsensitiveSearch];
        [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)[UIColor lightGrayColor].CGColor range:boldRange];
        return mutableAttributedString;
    }];
}

@end
