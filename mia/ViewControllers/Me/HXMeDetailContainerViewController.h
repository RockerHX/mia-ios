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
    HXProfileDetailContainerActionShowMusicDetail,
    HXProfileDetailContainerActionShowFans,
    HXProfileDetailContainerActionShowFollow,
    HXProfileDetailContainerActionShoulFollow,
	HXProfileDetailContainerActionShowMessageCenter
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
@property (weak, nonatomic) IBOutlet  UIView *footer;
@property (weak, nonatomic) IBOutlet  UIView *promptView;
@property (weak, nonatomic) IBOutlet UILabel *firstPromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondPromptLabel;

@property (nonatomic, strong)      NSString *uid;
@property (nonatomic, assign) HXProfileType  type;
@property (nonatomic, assign)    NSInteger  shareCount;
@property (nonatomic, assign)    NSInteger  favoriteCount;

@property (nonatomic, strong) IBOutlet HXMeDetailHeader *header;

- (void)showMessageWithAvatar:(NSString *)avatar count:(NSInteger)count;
- (void)stopMusic;

@end
