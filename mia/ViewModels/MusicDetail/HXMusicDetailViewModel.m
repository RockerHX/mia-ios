//
//  HXMusicDetailViewModel.m
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "HXMusicDetailViewModel.h"
#import "MiaAPIHelper.h"
#import "CommentModel.h"
#import "HXComment.h"

typedef void(^CommentReuqestBlock)(BOOL);

@implementation HXMusicDetailViewModel {
    CommentReuqestBlock _commentReuqestBlock;
    
    NSArray *_rowTypes;
    CommentModel *_dataModel;
    ShareItem *_playItem;
}

#pragma mark - Init Methods
- (instancetype)initWithItem:(ShareItem *)item {
    self = [super init];
    if (self) {
        if (item) {
            _playItem = item;
            _frontCoverURL = [NSURL URLWithString:item.music.purl];
            
            [self initConfig];
        }
    }
    return self;
}

#pragma mark - Config Methods
- (void)initConfig {
    _dataModel = [[CommentModel alloc] init];
    
    [self setupRowTypes];
}

- (void)setupRowTypes {
    _rowTypes = @[@(HXMusicDetailRowCover),
                  @(HXMusicDetailRowSong),
                  @(HXMusicDetailRowShare),
                  @(HXMusicDetailRowInfect),
                  @(HXMusicDetailRowPrompt),
                  @(HXMusicDetailRowNoComment)];
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
    return 80.0f;
}

static NSInteger RegularRow = 5;
- (NSInteger)rows {
    return (_playItem ? RegularRow + (_dataModel.dataSource.count ?: 1) : 0);
}

- (NSInteger)regularRow {
    return RegularRow;
}

- (NSArray *)rowTypes {
    return _rowTypes;
}

- (NSArray *)comments {
    return [_dataModel.dataSource copy];
}

#pragma mark - Public Methods
- (void)requestComments:(void(^)(BOOL success))block {
    _commentReuqestBlock = block;
    
    __weak __typeof__(self)weakSelf = self;
    static NSInteger kCommentPageItemCount	= 10;
    [MiaAPIHelper getMusicCommentWithShareID:_playItem.sID
                                       start:_dataModel.lastCommentID
                                        item:kCommentPageItemCount
                               completeBlock:
     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
         __strong __typeof__(self)strongSelf = weakSelf;
         if (!success) {
             if (strongSelf->_commentReuqestBlock) {
                 strongSelf->_commentReuqestBlock(NO);
             }
             return;
         }
         
         NSArray *commentArray = userInfo[@"v"][@"info"];
         if (!commentArray.count) {
             if (strongSelf->_commentReuqestBlock) {
                 strongSelf->_commentReuqestBlock(NO);
             }
             return;
         }
         
         [strongSelf->_dataModel addComments:commentArray];
         [strongSelf reSetupRowTypes];
         
         if (strongSelf->_commentReuqestBlock) {
             strongSelf->_commentReuqestBlock(YES);
         }
     } timeoutBlock:^(MiaRequestItem *requestItem) {
         __strong __typeof__(self)strongSelf = weakSelf;
         if (strongSelf->_commentReuqestBlock) {
             strongSelf->_commentReuqestBlock(NO);
         }
     }];
}

- (void)requestLatestComments {
//    [MiaAPIHelper getMusicCommentWithShareID:_playItem.sID
//                                       start:_dataModel.latestCommentID
//                                        item:1
//                               completeBlock:
//     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
//         if (!success) {
//             [self checkPlaceHolder];
//             return;
//         }
//         
//         NSArray *commentArray = userInfo[@"v"][@"info"];
//         if (!commentArray || [commentArray count] <= 0) {
//             [self checkPlaceHolder];
//             return;
//         }
//         
//         [_dataModel addComments:commentArray];
//     } timeoutBlock:^(MiaRequestItem *requestItem) {
//         NSLog(@"Time out");
//     }];
}

#pragma mark - Private Methods
- (void)reSetupRowTypes {
    NSMutableArray *array = [NSMutableArray arrayWithArray:_rowTypes];
    NSArray *comments = [NSArray arrayWithArray:_dataModel.dataSource];
    if (comments.count) {
        HXMusicDetailRow rowType = [[array lastObject] integerValue];
        if (rowType == HXMusicDetailRowNoComment) {
            [array removeLastObject];
        }
        
        for (NSInteger index = 0; index < comments.count; index++) {
            [array addObject:@(HXMusicDetailRowComment)];
        }
    }
    _rowTypes = [array copy];
}

@end
