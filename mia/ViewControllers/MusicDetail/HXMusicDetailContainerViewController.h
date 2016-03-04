//
//  HXMusicDetailContainerViewController.h
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HXMusicDetailViewModel.h"

@class HXComment;
@class HXMusicDetailContainerViewController;


@protocol HXMusicDetailContainerViewControllerDelegate <NSObject>

@required
- (void)containerViewControllerAtComment:(HXMusicDetailContainerViewController *)container at:(HXComment *)comment;

@end


@interface HXMusicDetailContainerViewController : UITableViewController

@property (weak, nonatomic) IBOutlet id  <HXMusicDetailContainerViewControllerDelegate>delegate;

@property (nonatomic, weak) HXMusicDetailViewModel *viewModel;

- (void)reload;

@end
