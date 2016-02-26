//
//  SearchSuggestionCollectionViewCell.h
//  mia
//
//  Created by linyehui on 2015-09-20.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SuggestionItem;

@interface SearchSuggestionCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) SuggestionItem *dataItem;

@end