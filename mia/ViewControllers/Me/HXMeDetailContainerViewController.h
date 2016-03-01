//
//  HXMeDetailContainerViewController.h
//  mia
//
//  Created by miaios on 16/1/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXMeDetailHeader.h"
#import "UIView+Frame.h"

typedef NS_ENUM(NSUInteger, HXProfileDetailContainerAction) {
    HXProfileDetailContainerActionShowSetting,
    HXProfileDetailContainerActionShowFans,
    HXProfileDetailContainerActionShowFollow,
    HXProfileDetailContainerActionShowMessageCenter,
    HXProfileDetailContainerActionShowMusicDetail,
};

@class HXMeDetailContainerViewController;

@protocol HXMeDetailContainerViewControllerDelegate <NSObject>

@optional
- (void)detailContainerDidScroll:(HXMeDetailContainerViewController *)controller
                    scrollOffset:(CGPoint)scrollOffset;
- (void)detailContainerDataFetchFinished:(HXMeDetailContainerViewController *)controller;
- (void)detailContainer:(HXMeDetailContainerViewController *)controller takeAction:(HXProfileDetailContainerAction)action;

@end

@interface HXMeDetailContainerViewController : UITableViewController

@property (weak, nonatomic) IBOutlet      id  <HXMeDetailContainerViewControllerDelegate>delegate;

@property (weak, nonatomic) IBOutlet HXMeDetailHeader *header;
@property (weak, nonatomic) IBOutlet           UIView *footer;
@property (weak, nonatomic) IBOutlet          UILabel *promptLabel;

@property (nonatomic, strong)      NSString *uid;

@end
