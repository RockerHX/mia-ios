//
//  HXFavoriteEditViewController.h
//  mia
//
//  Created by miaios on 16/3/2.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "UIViewController+HXClass.h"

@interface HXFavoriteEditViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *selectedAllButton;

- (IBAction)selectAllButtonPressed;
- (IBAction)doneButtonPressed;
- (IBAction)deleteButtonPressed;

@end
