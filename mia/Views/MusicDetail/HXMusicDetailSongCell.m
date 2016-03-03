//
//  HXMusicDetailSongCell.m
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXMusicDetailSongCell.h"
#import "TTTAttributedLabel.h"
#import "ShareItem.h"
#import "MusicItem.h"
#import "UIConstants.h"

@implementation HXMusicDetailSongCell

#pragma mark - Init Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initConfig];
}

#pragma mark - Config Methods
- (void)initConfig {
    _songInfoLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 30.0f;
}

#pragma mark - Public Methods
- (void)displayWithPlayItem:(ShareItem *)item {
	if (!item.hasData) {
		return;
	}
	
    MusicItem *musicItem = item.music;
    [self displaySongInfoLabelWithSongName:musicItem.name singerName:[@" - " stringByAppendingString:musicItem.singerName]];
}

#pragma mark - Private Methods
- (void)displaySongInfoLabelWithSongName:(NSString *)songerName singerName:(NSString *)singerName {
    NSString *text = [NSString stringWithFormat:@"%@%@", (songerName.length ? songerName : @""), ((singerName.length > 1) ? singerName : @"")];
    
    NSDictionary *linkAttributes = @{(__bridge id)kCTForegroundColorAttributeName: UIColorByHex(0x808080)};
    [_songInfoLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange boldRange = [text rangeOfString:singerName];
        if (singerName.length > 1) {
            [mutableAttributedString addAttributes:linkAttributes range:boldRange];
        }
        return mutableAttributedString;
    }];
}

@end
