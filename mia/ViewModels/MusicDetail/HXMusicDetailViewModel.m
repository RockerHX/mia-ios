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
#import "HXVersion.h"

typedef void(^CommentReuqestBlock)(BOOL);
typedef void(^SuccessBlock)(HXMusicDetailViewModel *);
typedef void(^FailureBlock)(NSString *);

@implementation HXMusicDetailViewModel {
    NSString *_sID;
    
    SuccessBlock _shareItemSuccessBlock;
    FailureBlock _shareItemFailureBlock;
    
    CommentReuqestBlock _commentReuqestBlock;
    CommentReuqestBlock _lastCommentReuqestBlock;
    CommentReuqestBlock _reportViewsBlock;
    
    NSInteger _rowCount;
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
            
            [self initConfig];
        }
    }
    return self;
}

- (instancetype)initWithID:(NSString *)ID {
    self = [super init];
    if (self) {
        _sID = ID;
    }
    return self;
}

#pragma mark - Config Methods
- (void)initConfig {
    [self setupRowTypes];
    _dataModel = [[CommentModel alloc] init];
    _rowCount = _rowTypes.count;
}

- (void)setupRowTypes {
    _rowTypes = @[@(HXMusicDetailRowCover),
                  @(HXMusicDetailRowSong),
                  @(HXMusicDetailRowShare),
                  @(HXMusicDetailRowPrompt)];
    _rowCount = _rowTypes.count;
}

#pragma mark - Setter And Getter
- (ShareItem *)playItem {
    return _playItem;
}

- (CGFloat)frontCoverCellHeight {
    return [HXVersion isIPhone5SPrior] ? 225.0f : 240.0f;
}

- (CGFloat)promptCellHeight {
    return 112.0f;
}

- (CGFloat)noCommentCellHeight {
    return 40.0f;
}

- (NSInteger)rows {
    return (_playItem ? _rowCount : 0);
}

- (NSInteger)regularRow {
    return 4;
}

- (NSArray *)rowTypes {
    return _rowTypes;
}

- (NSArray *)comments {
    return [_dataModel.dataSource copy];
}

#pragma mark - Public Methods
- (void)fetchShareItem:(void(^)(HXMusicDetailViewModel *))success failure:(void(^)(NSString *))failure {
    _shareItemSuccessBlock = success;
    _shareItemFailureBlock = failure;
    
    [MiaAPIHelper getShareById:_sID
                          spID:nil
                 completeBlock:
     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
         if (success) {
             _playItem = [[ShareItem alloc] initWithDictionary:userInfo[MiaAPIKey_Values][@"data"]];

             [self setupRowTypes];
             if (_shareItemSuccessBlock) {
                 _shareItemSuccessBlock(self);
             }
         } else {
             if (_shareItemFailureBlock) {
                 _shareItemFailureBlock(@"数据获取出错！");
             }
         }
     } timeoutBlock:^(MiaRequestItem *requestItem) {
         if (_shareItemFailureBlock) {
             _shareItemFailureBlock(@"请求超时！");
         }
     }];
}

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

- (void)requestLatestComments:(void(^)(BOOL success))block {
    _lastCommentReuqestBlock = block;
    
    __weak __typeof__(self)weakSelf = self;
    [MiaAPIHelper getMusicCommentWithShareID:_playItem.sID
                                       start:_dataModel.latestCommentID
                                        item:1
                               completeBlock:
     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
         __strong __typeof__(self)strongSelf = weakSelf;
         if (!success) {
             if (strongSelf->_lastCommentReuqestBlock) {
                 strongSelf->_lastCommentReuqestBlock(NO);
             }
             return;
         }
         
         NSArray *commentArray = userInfo[@"v"][@"info"];
         [strongSelf->_dataModel addComments:commentArray];
         [strongSelf reSetupRowTypes];
         
         if (strongSelf->_lastCommentReuqestBlock) {
             strongSelf->_lastCommentReuqestBlock(YES);
         }
     } timeoutBlock:^(MiaRequestItem *requestItem) {
         __strong __typeof__(self)strongSelf = weakSelf;
         if (strongSelf->_lastCommentReuqestBlock) {
             strongSelf->_lastCommentReuqestBlock(NO);
         }
     }];
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
             _playItem.cView = _playItem.cView + 1;

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

- (void)reload {
    [self fetchShareItem:_shareItemSuccessBlock failure:_shareItemFailureBlock];
}

#pragma mark - Private Methods
- (void)reSetupRowTypes {
    NSMutableArray *array = [NSMutableArray arrayWithArray:_rowTypes];
    NSArray *comments = [NSArray arrayWithArray:_dataModel.dataSource];
    _playItem.cComm = (int)comments.count;
    
    HXMusicDetailRow lastRowType = [[array lastObject] integerValue];
    if (lastRowType == HXMusicDetailRowNoComment) {
        [array removeLastObject];
    }
    
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HXMusicDetailRow rowType = [obj integerValue];
        if (rowType == HXMusicDetailRowComment) {
            [array removeObject:obj];
        }
    }];
    
    if (comments.count) {
        [comments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [array addObject:@(HXMusicDetailRowComment)];
        }];
    } else {
        [array addObject:@(HXMusicDetailRowNoComment)];
    }
    _rowCount = array.count;
    _rowTypes = [array copy];
}

@end
