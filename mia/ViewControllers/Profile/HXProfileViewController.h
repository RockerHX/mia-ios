//
//  HXProfileViewController.h
//  mia
//
//  Created by miaios on 16/1/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "UIViewController+HXClass.h"
#import "HXProfileDetailContainerViewController.h"

@class HXNavigationBar;

@interface HXProfileViewController : UIViewController

@property (weak, nonatomic) IBOutlet HXNavigationBar *navigationBar;

@property (nonatomic, assign) HXProfileType  type;
@property (nonatomic, strong)      NSString *uid;

@end
