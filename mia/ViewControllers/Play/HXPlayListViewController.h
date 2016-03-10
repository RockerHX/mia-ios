//
//  HXPlayListViewController.h
//  mia
//
//  Created by miaios on 16/2/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "UIViewController+HXClass.h"

@class HXPlayListViewController;

@protocol HXPlayListViewControllerDelegate <NSObject>

@optional
- (void)playListViewController:(HXPlayListViewController *)viewController playIndex:(NSInteger)index;

@end

@interface HXPlayListViewController : UITableViewController

@property (weak, nonatomic) IBOutlet id  <HXPlayListViewControllerDelegate>delegate;

@property (nonatomic, strong)   NSArray *musicList;
@property (nonatomic, assign) NSInteger  playIndex;

@end
