//
//  SearchSuggestionView.h
//  mia
//
//  Created by linyehui on 2015/09/29.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchSuggestionModel;
@class SuggestionItem;

@protocol SearchSuggestionViewDelegate

- (SearchSuggestionModel *)searchSuggestionViewModel;
- (void)searchSuggestionViewDidSelectedItem:(SuggestionItem *)item;

@end

@interface SearchSuggestionView : UIView

@property (weak, nonatomic)id<SearchSuggestionViewDelegate> searchSuggestionViewDelegate;
@property (strong, nonatomic) UICollectionView *suggestionCollectionView;

@end
