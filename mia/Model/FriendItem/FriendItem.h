//
//  FriendItem.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

@interface FriendItem : NSObject

@property (strong, nonatomic) NSString * songID;
@property (strong, nonatomic) NSString * title;
@property (strong, nonatomic) NSString * artist;
@property (strong, nonatomic) NSString * albumName;
@property (strong, nonatomic) NSString * pic;
@property (strong, nonatomic) NSString * albumPic;
@property (strong, nonatomic) NSString * songUrl;

@property (assign, nonatomic) BOOL isPlaying;

@end
