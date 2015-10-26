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

@interface HXMusicDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet HXMusicDetailView *detailView;
@property (weak, nonatomic) IBOutlet       UITableView *tableView;

@property (nonatomic, assign)      BOOL  formProfile;
@property (nonatomic, strong) ShareItem *playItem;

- (IBAction)moreButtonPressed;
- (IBAction)commentButtonPressed;

@end
