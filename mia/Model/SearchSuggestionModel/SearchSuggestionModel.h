//
//  SearchSuggestionModel.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchSuggestionModel : NSObject

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSString *lastID;
@property (nonatomic, assign) NSInteger currentPlaying;

- (void)addItemsWithArray:(NSArray *) items;

@end
