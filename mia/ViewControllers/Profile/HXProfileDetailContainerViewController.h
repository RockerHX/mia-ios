//
//  HXProfileDetailContainerViewController.h
//  mia
//
//  Created by miaios on 16/1/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXProfileDetailHeader.h"
#import "UIView+Extension.h"

@class HXProfileDetailContainerViewController;

@protocol HXProfileDetailContainerViewControllerDelegate <NSObject>

@optional
- (void)detailContainerDidScroll:(HXProfileDetailContainerViewController *)controller
                    scrollOffset:(CGPoint)scrollOffset;
- (void)detailContainerDataFetchFinished:(HXProfileDetailContainerViewController *)controller;
- (void)detailContainerWouldLikeShowFans:(HXProfileDetailContainerViewController *)controller;
- (void)detailContainerWouldLikeShowFollow:(HXProfileDetailContainerViewController *)controller;

@end

@interface HXProfileDetailContainerViewController : UITableViewController

@property (weak, nonatomic) IBOutlet     id  <HXProfileDetailContainerViewControllerDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIView *footer;

@property (nonatomic, assign) HXProfileType  type;

@property (nonatomic, strong) HXProfileDetailHeader *header;

@end
