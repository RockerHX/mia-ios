//
//  MusicItem.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <MJExtension/MJExtension.h>

@interface MusicItem : NSObject

@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *singerID;
@property (nonatomic, strong) NSString *singerName;
@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, strong) NSString *albumURL;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *flag;

@end
