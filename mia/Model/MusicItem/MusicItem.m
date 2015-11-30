//
//  MusicItem.m
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "MusicItem.h"

@implementation MusicItem

MJCodingImplementation

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"ID": @"mid",
       @"albumURL": @"purl",
            @"url": @"murl"};
}

- (instancetype)copyWithZone:(nullable NSZone *)zone {
    MusicItem *copyItem = [[[self class] allocWithZone:zone] init];
    copyItem.ID         = [_ID copy];
    copyItem.singerID   = [_singerID copy];
    copyItem.singerName = [_singerName copy];
    copyItem.albumName  = [_albumName copy];
    copyItem.name       = [_name copy];
    copyItem.albumURL   = [_albumURL copy];
    copyItem.url        = [_url copy];
    copyItem.flag       = [_flag copy];
    
    return copyItem;
}

@end
