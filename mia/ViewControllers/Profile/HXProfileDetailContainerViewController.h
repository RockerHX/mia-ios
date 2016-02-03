//
//  HXProfileDetailContainerViewController.h
//  mia
//
//  Created by miaios on 16/1/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXProfileDetailHeader.h"
#import "UIView+Extension.h"

typedef NS_ENUM(NSUInteger, HXProfileDetailContainerAction) {
    HXProfileDetailContainerActionShowMusicDetail,
    HXProfileDetailContainerActionShowFans,
    HXProfileDetailContainerActionShowFollow,
    HXProfileDetailContainerActionShoulFollow,
	HXProfileDetailContainerActionShowMessageCenter
};

@class HXProfileDetailContainerViewController;

@protocol HXProfileDetailContainerViewControllerDelegate <NSObject>

@optional
- (void)detailContainerDidScroll:(HXProfileDetailContainerViewController *)controller
                    scrollOffset:(CGPoint)scrollOffset;
- (void)detailContainerDataFetchFinished:(HXProfileDetailContainerViewController *)controller;
- (void)detailContainer:(HXProfileDetailContainerViewController *)controller takeAction:(HXProfileDetailContainerAction)action;

@end

@interface HXProfileDetailContainerViewController : UITableViewController

@property (weak, nonatomic) IBOutlet      id  <HXProfileDetailContainerViewControllerDelegate>delegate;
@property (weak, nonatomic) IBOutlet  UIView *footer;
@property (weak, nonatomic) IBOutlet  UIView *promptView;
@property (weak, nonatomic) IBOutlet UILabel *firstPromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondPromptLabel;

@property (nonatomic, strong)      NSString *uid;
@property (nonatomic, assign) HXProfileType  type;
@property (nonatomic, assign)    NSInteger  shareCount;
@property (nonatomic, assign)    NSInteger  favoriteCount;

@property (nonatomic, strong) HXProfileDetailHeader *header;

- (void)showMessageWithAvatar:(NSString *)avatar count:(NSInteger)count;
- (void)stopMusic;

@end
