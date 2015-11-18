//
//  HXHomePageViewController.h
//  mia
//
//  Created by miaios on 15/10/9.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXTopBar;
@class HXBottomBar;
@class HXRadioViewController;

@interface HXHomePageViewController : UIViewController

@property (weak, nonatomic) IBOutlet     HXTopBar *topBar;
@property (weak, nonatomic) IBOutlet  HXBottomBar *bottomBar;

@property (nonatomic, weak) HXRadioViewController *radioViewController;

@end
