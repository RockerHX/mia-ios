//
//  TVDetailViewController.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShareItem;

@interface TVDetailViewController : UIViewController <UIScrollViewDelegate>

- (id)initWitShareItem:(ShareItem *)item;

@end

