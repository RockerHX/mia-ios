//
//  FavoriteItem.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "MusicItem.h"

@interface FavoriteItem : NSObject <NSCoding>

@property (nonatomic, strong) NSString *sID;
@property (nonatomic, strong) NSString *uID;
@property (nonatomic, strong) NSString *sNick;
@property (nonatomic, strong) NSString *sDate;
@property (nonatomic, strong) NSString *sNote;
@property (nonatomic, strong) NSString *mID;
@property (nonatomic, strong) NSString *fID;

@property (nonatomic, strong) MusicItem *music;

@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isCached;

@end
