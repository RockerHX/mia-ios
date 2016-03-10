//
//  SearchResultView.h
//  mia
//
//  Created by linyehui on 2015/09/29.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchResultModel;
@class SearchResultItem;

@protocol SearchResultViewDelegate

- (SearchResultModel *)searchResultViewModel;
- (void)searchResultViewDidSelectedItem:(SearchResultItem *)item;
- (void)searchResultViewRequestMoreItems;
- (void)searchResultViewDidPlayItem:(SearchResultItem *)item;

@end

@interface SearchResultView : UIView

@property (weak, nonatomic)id<SearchResultViewDelegate> searchResultViewDelegate;
@property (strong, nonatomic) UICollectionView *collectionView;

- (void)setNoDataTipsHidden:(BOOL)hidden;
- (void)endRefreshing;
- (void)playCompletion;

@end
