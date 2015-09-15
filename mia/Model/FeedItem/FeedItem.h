//
//  FeedItem.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "MusicItem.h"

@interface FeedItem : NSObject

@property (strong, nonatomic) NSString *sID;
@property (strong, nonatomic) NSString *mID;
@property (strong, nonatomic) NSString *uID;
@property (strong, nonatomic) NSString *sGeohash;
@property (strong, nonatomic) NSString *freeChanceNum;
@property (strong, nonatomic) NSString *sAddress;
@property (strong, nonatomic) NSString *sNick;
@property (strong, nonatomic) NSString *sRemoteip;
@property (strong, nonatomic) NSString *sNote;
@property (assign, nonatomic) int cStar;
@property (assign, nonatomic) int cView;
@property (assign, nonatomic) int cComm;
@property (assign, nonatomic) int cShare;



- (id)initWithDictionary:(NSDictionary *)dictionary;
@end
