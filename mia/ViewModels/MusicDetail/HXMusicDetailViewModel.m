//
//  HXMusicDetailViewModel.m
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXMusicDetailViewModel.h"

@implementation HXMusicDetailViewModel {
    NSArray *_rowTypes;
    ShareItem *_playItem;
}

#pragma mark - Init Methods
- (instancetype)initWithItem:(ShareItem *)item {
    self = [super init];
    if (self) {
        if (item) {
            _playItem = item;
            _frontCoverURL = [NSURL URLWithString:item.music.murl];
            
        }
    }
    return self;
}

#pragma mark - Config Methods
- (void)initConfig {
    _rowTypes = @[@(HXMusicDetailRowCover),
                  @(HXMusicDetailRowSong),
                  @(HXMusicDetailRowShare),
                  @(HXMusicDetailRowInfect),
                  @(HXMusicDetailRowPrompt)];
}

#pragma mark - Setter And Getter
- (ShareItem *)playItem {
    return _playItem;
}

- (CGFloat)frontCoverCellHeight {
    return 240.0f;
}

- (CGFloat)infectCellHeight {
    return 35.0f;
}

- (CGFloat)promptCellHeight {
    return 89.0f;
}

- (CGFloat)noCommentCellHeight {
    return 100.0f;
}

static NSInteger RegularRow = 5;
- (NSInteger)rows {
    return (_playItem ? RegularRow + 0 : 0);
}

- (NSArray *)rowTypes {
    return _rowTypes;
}

@end
