//
//  HXHomePageViewController.h
//  mia
//
//  Created by miaios on 15/10/9.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXRadioViewController;

@interface HXHomePageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *profileButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (nonatomic, weak) HXRadioViewController *radioViewController;

- (IBAction)profileButtonPressed;
- (IBAction)shareButtonPressed;
- (IBAction)feedBackButtonPressed;
- (IBAction)commentButtonPressed;
- (IBAction)favoriteButtonPressed;
- (IBAction)moreButtonPressed;

@end
