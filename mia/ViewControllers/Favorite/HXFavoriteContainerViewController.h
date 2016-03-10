//
//  HXFavoriteContainerViewController.h
//  mia
//
//  Created by miaios on 16/2/22.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoriteMgr.h"

@class HXFavoriteHeader;
@class HXFavoriteContainerViewController;

@protocol HXFavoriteContainerViewControllerDelegate <NSObject>

@required
- (void)containerShouldShare:(HXFavoriteContainerViewController *)container item:(FavoriteItem *)item;

@end

@interface HXFavoriteContainerViewController : UITableViewController

@property (weak, nonatomic) IBOutlet               id  <HXFavoriteContainerViewControllerDelegate>delegate;
@property (weak, nonatomic) IBOutlet HXFavoriteHeader *header;

@end
