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

@implementation HXMusicDetailShareCell

#pragma mark - Init Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
    _shareInfoLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 42.0f;
}

#pragma mark - Public Methods
- (void)displayWithShareItem:(ShareItem *)item {
    _shareInfoLabel.text = [NSString stringWithFormat:@"%@：%@", item.sNick, item.sNote];
}

@end
