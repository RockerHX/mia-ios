//
//  HXFavoriteEditViewController.h
//  mia
//
//  Created by miaios on 15/12/1.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "UIViewController+HXClass.h"

@class HXFavoriteEditViewController;

@protocol HXFavoriteEditViewControllerDelegate <NSObject>

@required
- (void)favoriteEditViewControllerEdited:(HXFavoriteEditViewController *)favoriteEditViewController;

@end

@interface HXFavoriteEditViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet          id  <HXFavoriteEditViewControllerDelegate>delegate;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)selectAllButtonPressed;
- (IBAction)completedButtonPressed;

@end
