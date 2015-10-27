//
//  HXMusicDetailViewController.h
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShareItem;
@class HXMusicDetailView;

@protocol HXMusicDetailViewControllerDelegate

- (void)detailViewControllerDidDeleteShare;

@end

@interface HXMusicDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet HXMusicDetailView 				*detailView;
@property (weak, nonatomic) IBOutlet       UITableView 				*tableView;
@property (weak, nonatomic)id<HXMusicDetailViewControllerDelegate>	customDelegate;

@property (nonatomic, assign)      BOOL  fromProfile;
@property (nonatomic, strong) ShareItem *playItem;

- (IBAction)moreButtonPressed;
- (IBAction)commentButtonPressed;

@end
