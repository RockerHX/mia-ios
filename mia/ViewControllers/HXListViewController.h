//
//  HXListViewController.h
//  TipTop-User
//
//  Created by ShiCang on 15/10/21.
//  Copyright © 2015年 Outsourcing. All rights reserved.
//

#import "UIViewController+HXClass.h"

@interface HXListViewController : UITableViewController

@property (nonatomic, copy) NSArray *dataList;

- (void)loadConfigure;
- (void)viewConfigure;

- (void)fetchNewData;

- (void)endLoad;

@end
