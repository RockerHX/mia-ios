//
//  SearchViewController.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchResultItem;

@protocol SearchViewControllerDelegate

- (void)searchViewControllerDidSelectedItem:(SearchResultItem *)item;
- (void)searchViewControllerClickedPlayButtonAtItem:(SearchResultItem *)item;

@end


@interface SearchViewController : UIViewController

@property (weak, nonatomic)id<SearchViewControllerDelegate> searchViewControllerDelegate;

@end

