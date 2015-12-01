//
//  HXPlayerViewController.h
//  mia
//
//  Created by miaios on 15/12/1.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import "UIViewController+HXClass.h"

@class HXPlayerInfoView;

@interface HXPlayerViewController : UIViewController

@property (weak, nonatomic) IBOutlet      UIImageView *frontCover;
@property (weak, nonatomic) IBOutlet HXPlayerInfoView *infoView;

- (IBAction)backButtonPressed;

@end
