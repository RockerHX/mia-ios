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
    HXMusicDetailRowPrompt,
    HXMusicDetailRowNoComment,
    HXMusicDetailRowComment
};

@interface HXMusicDetailViewModel : NSObject

@property (nonatomic, strong, readonly) ShareItem *playItem;

@property (nonatomic, assign, readonly) CGFloat  frontCoverCellHeight;
@property (nonatomic, assign, readonly) CGFloat  promptCellHeight;
@property (nonatomic, assign, readonly) CGFloat  noCommentCellHeight;

@property (nonatomic, assign, readonly) NSInteger  rows;
@property (nonatomic, assign, readonly) NSInteger  regularRow;
@property (nonatomic, copy, readonly)     NSArray *rowTypes;

@property (nonatomic, copy, readonly)     NSArray *comments;

@property (nonatomic, strong, readonly)     NSURL *frontCoverURL;

- (instancetype)initWithItem:(ShareItem *)item;
- (instancetype)initWithID:(NSString *)ID;
- (void)fetchShareItem:(void(^)(HXMusicDetailViewModel *viewModel))success failure:(void(^)(NSString *message))failure;
- (void)requestComments:(void(^)(BOOL success))block;
- (void)reportViews:(void(^)(BOOL success))block;
- (void)requestLatestComments:(void(^)(BOOL success))block;

- (void)reload;

@end
