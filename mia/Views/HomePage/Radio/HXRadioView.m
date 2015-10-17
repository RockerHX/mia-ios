//
//  HXRadioView.m
//  mia
//
//  Created by miaios on 15/10/17.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXRadioView.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "ShareItem.h"
#import "UIImageView+WebCache.h"

@interface HXRadioView () <TTTAttributedLabelDelegate>

@end

@implementation HXRadioView

#pragma Init Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configLabel];
}

#pragma mark - Config Methods
- (void)configLabel {
    _shrareContentLabel.delegate = self;
    _shrareContentLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
}

#pragma mark - Class Methods
+ (instancetype)initWithFrame:(CGRect)frame delegate:(id<HXRadioViewDelegate>)delegate {
    HXRadioView *radioView = [[[NSBundle mainBundle] loadNibNamed:@"HXRadioView" owner:self options:nil] firstObject];
    radioView.frame = frame;
    radioView.delegate = delegate;
    
    return radioView;
}

#pragma mark - Event Response
- (IBAction)starButtonPressed:(UIButton *)button {
    button.selected = !button.selected;
    if (_delegate && [_delegate respondsToSelector:@selector(userWouldLikeStarMusic)]) {
        [_delegate userWouldLikeStarMusic];
    }
}

#pragma mark - Public Methods
- (void)displayWithItem:(ShareItem *)item {
    [_frontCoverView sd_setImageWithURL:[NSURL URLWithString:item.music.purl]];
    _songNameLabel.text = item.music.name;
    _songerNameLabel.text = item.music.singerName;
    _starButton.selected = item.favorite;
    _shrareContentLabel.text = [NSString stringWithFormat:@"%@:%@", item.sNick, item.sNote];
    _locationLabel.text = [item sAddress];
    
    [self displayShareContentLabelWithSharerName:item.sNick];
}

#pragma mark - Private Methods
- (void)displayShareContentLabelWithSharerName:(NSString *)sharerName {
    NSRange range = [_shrareContentLabel.text rangeOfString:(sharerName ?: @"")];
    [_shrareContentLabel addLinkToURL:[NSURL URLWithString:@""] withRange:range];
}

#pragma mark - TTTAttributedLabelDelegate Methods
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if (_delegate && [_delegate respondsToSelector:@selector(userWouldLikeSeeSharerHomePage)]) {
        [_delegate userWouldLikeSeeSharerHomePage];
    }
}

@end
