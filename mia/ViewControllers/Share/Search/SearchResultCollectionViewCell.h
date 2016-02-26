//
//  SearchResultCollectionViewCell.h
//  mia
//
//  Created by linyehui on 2015-09-20.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchResultItem;

@protocol SearchResultCellDelegate
- (void)searchResultCellClickedPlayButtonAtIndexPath:(NSIndexPath *)indexPath;
@end
	
@interface SearchResultCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) SearchResultItem *dataItem;
@property (strong, nonatomic) NSIndexPath *indexPath;

@property (weak, nonatomic)id<SearchResultCellDelegate> cellDelegate;

@end