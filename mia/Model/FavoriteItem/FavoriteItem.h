//
//  FavoriteItem.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "MusicItem.h"

@interface FavoriteItem : NSObject

@property (strong, nonatomic) NSString * uID;
@property (strong, nonatomic) NSString * sNick;
@property (strong, nonatomic) NSString * sDate;
@property (strong, nonatomic) NSString * sNote;
@property (strong, nonatomic) NSString * mID;
@property (strong, nonatomic) NSString * fID;

@property (strong, nonatomic) MusicItem *music;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
