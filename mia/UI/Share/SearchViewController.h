//
//  SearchViewController.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoriteModel.h"

@class SearchResultItem;

@protocol SearchViewControllerDelegate

- (void)searchViewControllerDisSelectedItem:(SearchResultItem *)item;
- (void)searchViewControllerDidPlayedItem:(SearchResultItem *)item;

@end


@interface SearchViewController : UIViewController

@property (weak, nonatomic)id<SearchViewControllerDelegate> searchViewControllerDelegate;

@end

