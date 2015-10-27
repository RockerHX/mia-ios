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
#import "LocationMgr.h"

typedef void(^CommentReuqestBlock)(BOOL);

@implementation HXMusicDetailViewModel {
    CommentReuqestBlock _commentReuqestBlock;
    CommentReuqestBlock _reportViewsBlock;
    
    NSInteger _regularRow;
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
    [self setupRowTypes];
    _dataModel = [[CommentModel alloc] init];
    _regularRow = _rowTypes.count;
}

- (void)setupRowTypes {
    if (_playItem.infectUsers.count) {
        _rowTypes = @[@(HXMusicDetailRowCover),
                      @(HXMusicDetailRowSong),
                      @(HXMusicDetailRowShare),
                      @(HXMusicDetailRowInfect),
                      @(HXMusicDetailRowPrompt)];
    } else {
        _rowTypes = @[@(HXMusicDetailRowCover),
                      @(HXMusicDetailRowSong),
                      @(HXMusicDetailRowShare),
                      @(HXMusicDetailRowPrompt)];
    }
}

#pragma mark - Setter And Getter
- (ShareItem *)playItem {
    return _playItem;
}

- (CGFloat)frontCoverCellHeight {
    return 240.0f;
}

- (CGFloat)infectCellHeight {
    return 46.0f;
}

- (CGFloat)promptCellHeight {
    return 77.0f;
}

- (CGFloat)noCommentCellHeight {
    return 40.0f;
}

- (NSInteger)rows {
    return (_playItem ? (_regularRow + _dataModel.dataSource.count) : 0);
}

- (NSInteger)regularRow {
    return _regularRow;
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

- (void)reportViews:(void(^)(BOOL success))block {
    _reportViewsBlock = block;
    
    __weak __typeof__(self)weakSelf = self;
    [MiaAPIHelper viewShareWithLatitude:[[LocationMgr standard] currentCoordinate].latitude
                              longitude:[[LocationMgr standard] currentCoordinate].longitude
                                address:[[LocationMgr standard] currentAddress]
                                   spID:_playItem.spID
                          completeBlock:
     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
         if (success) {
#warning @"Change View Count"
//             _playItem.cView = ;
             
             __strong __typeof__(self)strongSelf = weakSelf;
             if (strongSelf->_commentReuqestBlock) {
                 strongSelf->_commentReuqestBlock(YES);
             }
         }
     } timeoutBlock:^(MiaRequestItem *requestItem) {
         __strong __typeof__(self)strongSelf = weakSelf;
         if (strongSelf->_commentReuqestBlock) {
             strongSelf->_commentReuqestBlock(NO);
         }
     }];
}

#pragma mark - Private Methods
- (void)reSetupRowTypes {
    NSMutableArray *array = [NSMutableArray arrayWithArray:_rowTypes];
    NSArray *comments = [NSArray arrayWithArray:_dataModel.dataSource];
    
    HXMusicDetailRow rowType = [[array lastObject] integerValue];
    if (rowType == HXMusicDetailRowNoComment) {
        [array removeLastObject];
    }
    
    if (comments.count) {
        for (NSInteger index = 0; index < comments.count; index++) {
            [array addObject:@(HXMusicDetailRowComment)];
        }
    } else {
        [array addObject:@(HXMusicDetailRowNoComment)];
    }
    _regularRow = array.count;
    _rowTypes = [array copy];
}

@end
