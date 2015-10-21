//
//  DetailViewController.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareItem.h"

@interface DetailViewController : UIViewController

- (id)initWitShareItem:(ShareItem *)item fromMyProfile:(BOOL)fromMyProfile;

@end

