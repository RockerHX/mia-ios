//
//  HXFavoriteViewModel.h
//  mia
//
//  Created by miaios on 15/11/30.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "FavoriteItem.h"

@interface HXFavoriteViewModel : NSObject

@property (nonatomic, strong, readonly) FavoriteItem *item;

@property (nonatomic, assign, readonly) BOOL selected;
@property (nonatomic, assign, readonly) BOOL playing;
@property (nonatomic, assign, readonly) BOOL cached;

- (instancetype)initWithFavoriteItem:(FavoriteItem *)item;

@end
