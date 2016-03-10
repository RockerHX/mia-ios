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
            
            [self initConfigure];
        }
    }
    return self;
}

- (instancetype)initWithID:(NSString *)ID {
    self = [super init];
    if (self) {
        _sID = ID;
        [self initConfigure];
    }
    return self;
}

#pragma mark - Config Methods
- (void)initConfigure {
    [self setupRowTypes];
    _dataModel = [[CommentModel alloc] init];
}

- (void)setupRowTypes {
    _rowTypes = @[@(HXMusicDetailRowCover),
                  @(HXMusicDetailRowSong),
                  @(HXMusicDetailRowShare),
                  @(HXMusicDetailRowPrompt)];
}

#pragma mark - Setter And Getter
- (ShareItem *)playItem {
    return _playItem;
}

- (CGFloat)coverCellHeight {
    return 230.0f;
}

- (CGFloat)promptCellHeight {
    return 186.0f;
}

- (CGFloat)noCommentCellHeight {
    return 100.0f;
}

- (NSInteger)rows {
    return (_playItem ? _rowTypes.count : 0);
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
    
    NSString *ID = _playItem.sID ?: _sID;
    [MiaAPIHelper getShareById:ID
                          spID:nil
                 completeBlock:
     ^(MiaRequestItem *requestItem, BOOL success, NSDictionary *userInfo) {
         if (success) {
			 ShareItem *newItem = [[ShareItem alloc] initWithDictionary:userInfo[MiaAPIKey_Values][@"data"]];
			 
			 // 手动更新数据，而不是整个替换，这个可以保证所有页面用的ShareItem是同一个对象，方便数据同步
			 // @eden 2016-03-04 16:52
			 if (_playItem) {
				 _playItem.infectUsers = newItem.infectUsers;
				 _playItem.infectTotal = newItem.infectTotal;
				 _playItem.starCnt = newItem.starCnt;
				 _playItem.shareCnt = newItem.shareCnt;
				 _playItem.favorite = newItem.favorite;
				 _playItem.isInfected = newItem.isInfected;
			 } else {
				 _playItem = newItem;
			 }

             [self setupRowTypes];
             if (_shareItemSuccessBlock) {
                 _shareItemSuccessBlock(self);
             }
         } else {
             if (_shareItemFailureBlock) {
                 _shareItemFailureBlock(@"数据获取出错");
             }
         }
     } timeoutBlock:^(MiaRequestItem *requestItem) {
         if (_shareItemFailureBlock) {
             _shareItemFailureBlock(@"请求超时");
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
    _rowTypes = [array copy];
}

@end
