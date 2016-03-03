//
//  HXMusicDetailContainerViewController.h
//  mia
//
//  Created by miaios on 15/10/26.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HXMusicDetailViewModel.h"

@interface HXMusicDetailContainerViewController : UITableViewController

@property (nonatomic, weak) HXMusicDetailViewModel *viewModel;

- (void)reload;

@end
