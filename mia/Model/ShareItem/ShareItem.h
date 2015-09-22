//
//  ShareItem.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "MusicItem.h"

@interface ShareItem : NSObject <NSCoding>

@property (strong, nonatomic) NSString *spID;
@property (strong, nonatomic) NSString *sID;
@property (strong, nonatomic) NSString *uID;
@property (strong, nonatomic) NSString *sNick;
@property (strong, nonatomic) NSString *sNote;
@property (assign, nonatomic) int cView;
@property (assign, nonatomic) int cComm;
@property (strong, nonatomic) NSString *sAddress;
@property (strong, nonatomic) NSString *sLongitude;
@property (strong, nonatomic) NSString *sLatitude;

@property (strong, nonatomic) MusicItem *music;

@property (assign, nonatomic) BOOL unread;
@property (assign, nonatomic) BOOL favorite;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
