//
//  SearchViewController.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchResultItem;

@protocol SearchViewControllerDelegate <NSObject>

@required
- (void)searchViewControllerDidSelectedItem:(SearchResultItem *)item;
- (void)searchViewControllerClickedPlayButtonAtItem:(SearchResultItem *)item;

@optional
- (void)searchViewControllerDismissFinished;

@end


@interface SearchViewController : UIViewController

@property (weak, nonatomic) id  <SearchViewControllerDelegate>delegate;

@end

