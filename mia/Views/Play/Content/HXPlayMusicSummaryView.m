//
//  HXPlayMusicSummaryView.m
//  mia
//
//  Created by miaios on 16/2/25.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXPlayMusicSummaryView.h"
#import "HXXib.h"
#import "MusicItem.h"
#import "UIImageView+WebCache.h"

@implementation HXPlayMusicSummaryView

HXXibImplementation

#pragma mark - Load Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    ;
}

- (void)viewConfigure {
    _containerView.backgroundColor = [UIColor clearColor];
}

#pragma mark - Event Response
- (IBAction)coverTapedGesture {
    if (_delegate && [_delegate respondsToSelector:@selector(summaryViewTaped:)]) {
        [_delegate summaryViewTaped:self];
    }
}

#pragma mark - Public Methods
- (void)displayWithMusic:(MusicItem *)music {
    [_cover sd_setImageWithURL:[NSURL URLWithString:music.purl] placeholderImage:nil];
    _songNameLabel.text = music.name;
    _singerNameLabel.text = music.singerName;
}

@end
