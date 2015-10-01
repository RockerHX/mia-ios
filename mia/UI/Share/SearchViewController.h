//
//  SearchViewController.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoriteModel.h"

@protocol SearchViewControllerDelegate

@end


@interface SearchViewController : UIViewController

@property (weak, nonatomic)id<SearchViewControllerDelegate> searchViewControllerDelegate;

@end

