//
//  HXMusicDetailViewController.h
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShareItem;
@class HXCardDetailView;

@protocol HXMusicDetailViewControllerDelegate <NSObject>

@optional
- (void)detailViewControllerDidDeleteShare;
- (void)detailViewControllerDismissWithoutDelete;

@end

@interface HXMusicDetailViewController : UIViewController

@property (nonatomic, weak, nullable) IBOutlet id  <HXMusicDetailViewControllerDelegate>delegate;

@property (nonatomic, weak, nullable) IBOutlet HXCardDetailView *detailView;

@property (nonatomic, strong, nullable) ShareItem *playItem;

@end
