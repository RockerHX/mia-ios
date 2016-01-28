//
//  HXProfileDetailContainerViewController.h
//  mia
//
//  Created by miaios on 16/1/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXProfileDetailContainerViewController;

@protocol HXProfileDetailContainerViewControllerDelegate <NSObject>

@optional
- (void)detailContainerDidScroll:(HXProfileDetailContainerViewController *)controller
                            scrollOffset:(CGPoint)scrollOffset;
- (void)detailContainerDataFetchFinished:(HXProfileDetailContainerViewController *)controller;

@end

@interface HXProfileDetailContainerViewController : UITableViewController

@property (weak, nonatomic) IBOutlet id  <HXProfileDetailContainerViewControllerDelegate>delegate;

@end
