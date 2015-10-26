//
//  HXMusicDetailViewModel.h
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareItem.h"

typedef NS_ENUM(NSUInteger, HXMusicDetailRow) {
    HXMusicDetailRowCover,
    HXMusicDetailRowSong,
    HXMusicDetailRowShare,
    HXMusicDetailRowInfect,
    HXMusicDetailRowPrompt,
    HXMusicDetailRowNoComment,
    HXMusicDetailRowComment
};

@interface HXMusicDetailViewModel : NSObject

@property (nonatomic, strong, readonly) ShareItem *playItem;

@property (nonatomic, assign, readonly) CGFloat  frontCoverCellHeight;
@property (nonatomic, assign, readonly) CGFloat  infectCellHeight;
@property (nonatomic, assign, readonly) CGFloat  promptCellHeight;
@property (nonatomic, assign, readonly) CGFloat  noCommentCellHeight;

@property (nonatomic, assign, readonly) NSInteger  rows;
@property (nonatomic, assign, readonly)   NSArray *rowTypes;

@property (nonatomic, strong, readonly)     NSURL *frontCoverURL;

- (instancetype)initWithItem:(ShareItem *)item;

@end
